# Phase 13r — Distribution Mechanics (the Sparkle round)

> **✔ CLOSED 2026-10-04** — see `## PHASE 13r — CLOSEOUT` at the end of this file and the closeout archive. *(Banner added 2026-10-08: the OPEN status line below is history.)*

**STATUS: OPEN — RESUMED 2026-10-04 (`/architect-phase 13r`, her invocation; the Fable
orchestrator seat). The kickoff sitting is COMPLETE: every ruling is made (R-13r-1…9 below),
the plan is fully made. The LIVE STATUS block at the bottom carries the resume record and the
per-unit state.**

---

## KICKOFF (self-contained — for this orchestrator's successor, or any fresh session)

You are the orchestrator for Phase 13r under `/architect-phase` (the skill file governs; CLAUDE.md's
standing rules bind). **Read first:** CLAUDE.md (auto-loads the spec set) · this file IN FULL ·
`notes/PhaseSizingGuidance.md` · the KnownIssues row owned by 13r (the keychain-access-groups row) ·
`notes/plans/13y-deploy-checklist.md` §10 (the live state: marker 9, both her devices enrolled and
syncing, signup auto-entitles — the friends beta needs ONLY this phase's distributable build) ·
`notes/SessionResiliencyProtocol.md`. **The sitting already ruled everything product-flavored**
(R-13r-1…9 below); build to the rulings, never re-litigate on no new grounds. Cast: `opus-implementer`
per unit, strictly sequential; ONE `fable-reviewer` ladder over the combined diff at the end. Author
steps (certs, portal, credentials, key minting, walks) PAUSE for her — never worked around. Commit
per piece, push after each, no attribution trailers. The phase ends: ladder → closeout ritual →
author handoff → hard stop. Then 🍰 the friends beta is hers to open.

## The row's letter (scope)

From the 13r row (moved back into the master plan at this kickoff): **Sparkle auto-update** (her
dependency approval 2026-08-20, verbatim: *"I think Sparkle sounds fine to use"* — MIT; re-affirmed
standing at this sitting, not re-opened) · the app is SANDBOXED so **Sparkle rides the XPC installer
road** · **the notarized DMG** · **opt-in crash reporting** consistent with the privacy story ·
**a support/feedback channel** (ruled IN at the sitting, minimal) · **the accessibility pass** over
the custom decoration language (VoiceOver on take cards, seams, chips) · **the in-app What's New
surface** (her word: necessary) · **the version-numbering scheme**, decided before the first public
number exists. **The lockstep synergy is the point:** auto-update shrinks any future §12
refuse-to-sync window from weeks to hours (13i's event, post-beta, depends on this).

**Explicitly OUT:** DMG background art + the app icon (13s's brand-assets item — 13r ships a clean
functional DMG) · copy re-voicing (13s; U3's strings are functional and honest) · the website
download page's content (the site agent's, via the outbound brief) · mobile distribution (the App
Store road, the mobile project's) · first-run onboarding (13s).

## Binding principles (the 13b constitution, P-1…P-9 — copied per the skill; BINDING here)

- **P-1 — One capability registry.** Every user-facing act is declared exactly once: verb, scope
  (block/take/post/book), per-mode availability rule, its doors (menu / context / bar / shortcut /
  palette), and its refusal copy. Surfaces render their doors FROM the registry; gating is data,
  never per-view if-statements. A registry-walk test asserts every declared door exists and every
  rendered door is declared. This kills the D3/D4 class structurally — the capability matrix stays
  green by construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act — including any mode-switch
  choreography, done visibly for the user — or delivers the operations layer's real refusal. A door
  that can never act in its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface component (live + read modes;
  one measurement brain — the width-gated remeasure; the shared canary) that every pane composes;
  the live editor core's identity machinery (`BlockRangeIndex`, crystallization) becomes its live
  mode, not a sibling implementation. "What text does this pane show, and is it live" is answered by
  ONE pure, unit-tested authority (`PaneTextAuthority`); views never re-derive it. Its invariants
  stated as code: exactly one live pane; the live pane is buffer-authoritative; read panes are
  projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter may announce that
  something happened (mode changed, post opened); no listener derives business state or availability
  from a broadcast, and no flow's correctness depends on broadcast ordering. Cross-feature flows
  route through composition. (Stage 0's survey enumerates today's notification bus; Stage 1
  disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule marks an
  under-architected feature. The response is never another patch: write the feature's DESIGN MEMO —
  intended behavior whole, edge cases enumerated on paper, refusal wordings, undo story — get the
  author's rulings on the product-flavored edges, then build to the memo. Happy path ships first,
  but the edges are *decided at design time*, not discovered by the author. First two memos owed:
  **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial flow is the contract for
  every happy path. It stays green — automated where the harness allows, screenshot-walked otherwise
  — and any change that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive harness: the ops-layer soaks
  (exist), the board/view-model invariant soak (Stage 1), the registry walk (P-1), the per-batch
  scripted screenshot walkthrough. Red-on-old stays absolute: no bug-class fix without a pin that
  fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind the rebuilt layer exactly
  as they bind the substrate (invalidation ∝ realized rows; one live editor; virtualized long
  views). Overlays, never rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit`
  (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary. Complexity lives in the
  store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing board layout, text authority,
  and gesture routing splits by concern (`TakesViewModel` at 890 lines is the standing
  counterexample). Same hygiene rule as the substrate, applied where it was being waived.

## THE SITTING RECORD (2026-09-25 — the author present; decisions taken via the question tool, her
selections recorded; recommended options are marked where she took them)

- **R-13r-1 — EdDSA key custody: the login Keychain + a password-manager backup** (recommended,
  taken). `generate_keys` keeps the private key in her login Keychain (its default); ONE backup copy
  exported via `generate_keys -x` goes into her password manager at the key-minting step. No key
  material in the repo or beside it. The leak story, recorded: a leaked key + control of the appcast
  = malicious updates to beta users; Sparkle's Apple code-signing layer sits on top, and rotation
  after a leak rides a Developer-ID-signed DMG transition update (the documented road).
- **R-13r-2 — Hosting: stargazing.tech** (recommended, taken). `appcast.xml` + the DMGs live on her
  site; the outbound brief is `notes/stargazing-13r-distribution-brief.md`, HERS to carry to the
  site agent (this repo's agents never touch that repo). The shipped feed URL bakes the site path;
  the walk uses a local override (never the public feed).
- **R-13r-3 — The support/feedback channel is IN, minimal** (recommended, taken — the row included
  it; her kickoff scope had omitted it and the sitting resolved the discrepancy). Help ▸ Send
  Feedback… opens a mail draft to **support@stargazing.tech** (R-13r-9's pick; the brief asks the
  site/domain setup to include the mailbox). Nothing is ever sent silently.
- **R-13r-4 — CAPTCHA stays UNARMED** (recommended, taken). QUESTIONS #145(a)'s re-surface-at-the-
  beta's-start happened at this sitting; her call: keep the lean — the fences are layered (the 13y
  abuse guard, auth rate limits, required email confirmation, the per-account kill-switch) and the
  beta is friends-only. Arm only if abuse appears. #145(a) carries the dated ruling.
- **R-13r-5 — Crash reporting: MetricKit, ZERO new dependency** (recommended, taken).
  `MXCrashDiagnostic` is SDK-CONFIRMED on macOS (`API_AVAILABLE(ios(14.0), macos(12.0))`, read from
  the macOS 26.2 SDK headers on this machine — not a web claim). Opt-in, **default OFF, provably**
  (a LOCAL machine preference on the 18j appearance-choice pattern — never a synced `setting`); when
  ON the app subscribes; every payload is shown to the user VERBATIM before anything leaves the
  machine; send = the support door's mail draft with the report attached. The sandbox blocks the
  read-the-system's-.ips road, which is why the options were MetricKit / PLCrashReporter / defer —
  MetricKit avoids the dependency call entirely. Trade-off accepted: delivery on the OS's schedule
  (typically next launch, up to ~24h), not instant.
- **R-13r-6 — The version scheme: 0.9.x for the friends beta → 1.0.0 reserved for 🚀** (recommended,
  taken). MARKETING_VERSION → **0.9.0** now (today's untouched `1.0` retires before any public
  number exists); 0.9.x increments per beta release. **The build number is automated on EVERY
  build:** `git rev-list --count HEAD` stamped into CFBundleVersion by a build phase that runs
  before signing — monotonic, commit-tied, all configurations.
- **R-13r-7 — Daily-drive coexistence: the hand-copy convention is UNCHANGED; Sparkle stays quiet
  on her machine** (recommended, taken). Because R-13r-6's stamping runs on every build, her
  hand-copied tip Release always outranks the appcast, so the update check runs and offers nothing.
  The real updater is exercised per release in the acceptance walk on a SCRATCH install — **update
  testing never touches `/Applications` and never touches the real store.** Debug builds never start
  the updater against the public feed (the dev fence extends to the update channel).
- **R-13r-8 — The walk target: a fresh macOS user account on the M3** (recommended, taken). Clean
  Keychain, clean container — Gatekeeper on the quarantined DMG, first-run, and the full Sparkle
  update cycle, all real. Honest limitation recorded: same machine; **the friends' first installs
  are the true second-machine evidence**, with the support door ready for exactly that.
- **R-13r-9 — Units, cast, shape, address: RATIFIED.** The four units below; Fable orchestrator
  (the sitting's session) · `opus-implementer` per unit · ONE `fable-reviewer` ladder over the
  combined diff (custody + the update channel's trust surface — the Fable-review rule binds);
  `/architect-phase` continuing in the sitting's session; **support@stargazing.tech** as the
  support/crash address.
- **Standing, re-affirmed rather than ruled:** Sparkle's dependency approval (2026-08-20, MIT) was
  NOT re-opened; the sitting confirmed it stands.

## External facts (verified 2026-09-25; the load-bearing ones)

- **Sparkle 2.10.0** (2026-09-13) is current; MIT (LICENSE fetched); min deployment macOS 12 — fine.
- **Sandboxing (Sparkle's own doc):** `SUEnableInstallerLauncherService = YES` (Info.plist) is
  REQUIRED for sandboxed apps; the **Downloader XPC service is NOT used** — the app already carries
  `com.apple.security.network.client` (the doc says don't enable it in that case); the app's
  entitlements gain the two mach-lookup temporary exceptions:
  `$(PRODUCT_BUNDLE_IDENTIFIER)-spks` and `$(PRODUCT_BUNDLE_IDENTIFIER)-spki` (the variable keeps
  the Debug/Release fence whole, exactly like the keychain groups).
- **`generate_keys`**: private key → login Keychain; `-x` exports (the PM backup), `-f` imports.
  The public key ships as `SUPublicEDKey`. Sparkle layers EdDSA + Apple code-signing checks; key
  rotation rides Developer-ID-signed DMG updates.
- **MetricKit:** SDK-verified locally (see R-13r-5) — the one externally-synthesized claim was
  replaced by a direct header read.
- **Developer ID + restricted entitlements:** `keychain-access-groups` on a Developer ID build needs
  an embedded **Developer ID provisioning profile** (`embedded.provisionprofile`); the profile's
  entitlements carry the team-wildcard groups (`TEAMID.*`) — the same wildcard the Mac Development
  team profile was measured to carry at pre-13x batch 0. Portal-created; HER hands.
- **notarytool:** App Store Connect API key (recommended) or app-specific password;
  `xcrun notarytool store-credentials` keeps a named profile in the Keychain. **Stapling:** the
  belt-and-braces flow staples BOTH — notarize the app (zipped), staple it, build the DMG from the
  stapled app, sign the DMG, notarize the DMG, staple the DMG — so an app extracted from the DMG
  still validates offline. DMG built with plain scripted `hdiutil` (no new tooling).
- **Machine facts:** ENABLE_APP_SANDBOX=YES, ENABLE_HARDENED_RUNTIME=YES, GENERATE_INFOPLIST_FILE=YES
  (Sparkle keys ride the existing partial-Info.plist road — the 17o row-10 precedent),
  CODE_SIGN_STYLE=Automatic (stays; the Developer ID export uses its own exportOptions), bundle ids
  *[removed for publication]*
  exists on this Mac today** — the Developer ID cert is minted in U1.

## HER HANDS (the author steps, in order; each PAUSES the phase for her)

*[removed for publication]*
   **Developer ID Application certificate**; create the **Developer ID provisioning profile** for
   `io.lduarte.Variorum` (portal: Certificates, Identifiers & Profiles ▸ Profiles ▸ + ▸ Developer
   ID, against the App ID with Keychain Sharing) and hand the file to the session.
2. **notarytool credential** (U1): mint an App Store Connect API key (or an app-specific password)
   and run the `store-credentials` line the session gives her.
3. **EdDSA minting** (U2's start): run `generate_keys`, then `generate_keys -x` and put the export
   in her password manager (R-13r-1).
4. **The mailbox:** create/confirm `support@stargazing.tech` (with the site agent / domain host).
5. **Carry the outbound brief** (`notes/stargazing-13r-distribution-brief.md`) to the site agent.
6. **The U1 drill's launch** (behind the A1 rail) and spot-checks of the U2/U3 walks; the U4
   VoiceOver spot-check is invited, not owed.

## THE UNITS (four; one implementer session each; strictly sequential U1 → U2 → U3/U4)

### U1 — The Developer ID identity + the keychain drill (the KnownIssues row, resolved here)

**Goal:** a Developer-ID-signed, notarization-ready Release export that keeps every keychain item
reachable. **Build:** the archive/export road (`Tools/Release/` gains `archive-and-export`, an
exportOptions.plist with method developer-id + the profile; the scheme's Run config stays Debug —
CLAUDE.md's fence); notarytool credential stored (her step 2). **The drill (the acceptance):**
(a) STATIC — `codesign -d --entitlements -` on the export shows **BOTH** groups
*[removed for publication]*
file's own comment names both; the KnownIssues row named one) plus the sandbox + hardened runtime;
`security cms -D -i embedded.provisionprofile` shows the profile authorizes them; (b) LIVE — behind
the **A1 rail** (byte backup of the closed store + all key files first, zero-instance window), SHE
launches the Developer-ID build once: custody reads (Touch ID lands), the store opens, quit. The
`CustodyHandover` guard turns a wrong identity into a visible refusal, and the rail makes even that
recoverable — but the drill exists so it never fires for a user. **Review flag:** custody-adjacent —
the ladder's Fable reviewer attends here. **Closes:** the KnownIssues keychain-access-groups row.

### U2 — Sparkle + the XPC road + the notarized DMG + the appcast (THE PHASE-SIZED UNIT)

**Build:** Sparkle 2.10.0 via SPM (Mac target ONLY — never the mobile target); the partial
Info.plist gains `SUPublicEDKey`, the stargazing.tech `SUFeedURL`, `SUEnableInstallerLauncherService`
= YES; the entitlements gain the two `-spks`/`-spki` mach-lookup exceptions (the
`$(PRODUCT_BUNDLE_IDENTIFIER)` form); the updater is instantiated only outside DEBUG (R-13r-7's
fence) with Sparkle's standard consent flow (it ASKS before automatic checks — the calm default);
`Tools/Release/` grows the full pipeline: stamp → archive → export → notarize+staple app → hdiutil
DMG → sign → notarize+staple DMG → `generate_appcast`. dSYMs are retained per released version (the
crash story's symbolication depends on them). **The walk (the acceptance, R-13r-8):** on the fresh
user account, 0.9.0's DMG with the quarantine attribute applied opens Gatekeeper-clean
(`spctl -a -vv` accepted), installs to that account's `~/Applications`, first-runs on a fresh
container store; then a locally-served 0.9.1 appcast (feed override via defaults on the SCRATCH
install only) drives the full Sparkle cycle — consent, download, the XPC install, relaunch as
0.9.1. Captured. Her app is quit for the walk's window (the zero-instance discipline, kept simple).
**Review flag:** the update channel's trust surface — Fable.

### U3 — What's New + the version scheme + crash reporting + the support door

**Build:** R-13r-6's stamping build phase (all configurations, before signing) + MARKETING_VERSION
0.9.0; per-version release-notes source in the repo — ONE source feeding the in-app What's New
(shown once when the version changes, + a Help ▸ What's New door; voice-conformant chrome per P-8)
AND the appcast's release notes (the release script renders both); the MetricKit subscriber behind
the LOCAL opt-in preference (R-13r-5) with an injected registration seam so the OFF state is
PINNABLE; a Diagnostics surface listing received payloads verbatim with a per-report Send (the mail
draft); Help ▸ Send Feedback… (the support door; draft pre-filled with app + OS versions, visible to
the user before sending). Settings placement of the opt-in + Diagnostics: the implementer PROPOSES,
the architect rules (the in-batch fork rule) — nine panes exist and none is obviously "Diagnostics".
**Acceptance:** walks — the What's New show-once across a simulated version bump; crash reporting
provably OFF (the pin: no registration when off) and the surface exercised via an injected synthetic
payload; the REAL MetricKit delivery is verified opportunistically (Apple controls delivery timing —
a beta-era crash proves the last leg; recorded honestly, not overclaimed). **Note:** the crash
toggle's copy states the privacy story plainly (nothing leaves the machine without your hand —
consistent with "no analytics OUT LOUD").

**U3 AMENDED AT THE U2 WALK SITTING (2026-10-04) — her two rulings join the unit (the LIVE
STATUS's walk-sitting bullet carries her words verbatim):**
- **R-13r-10 — the self-explaining DMG window.** `release.sh`'s DMG step (U2's pipeline,
  `Tools/Release/`) lays out the window: the app icon and the Applications link at FIXED
  positions, a plain "drag here" arrow or label between them, a fixed window size, no
  toolbar/sidebar. Plain `hdiutil` + scripted Finder window settings (the `.DS_Store` written
  by AppleScript against the mounted read-write image before conversion) — no new dependency.
  Functional layout only; the branded background art is 13s's. The notarize/staple order is
  unchanged (the layout is set before the DMG is signed). The in-app "running from the disk
  image" notice was offered alongside and is NOT ruled — do not build it.
- **R-13r-11 — no popup at first open: Sparkle's consent is deferred until after real use.**
  U2 shipped Sparkle's stock flow (the "Check for updates automatically?" prompt on the
  second launch). U3 replaces the timing: `UpdateChannel` gains an updater delegate that
  declines Sparkle's early permission prompt (`updaterShouldPromptForPermissionToCheck…` →
  false, read from the 2.10.0 source before relying on it) and asks LATER, once a usage
  threshold is met. No automatic check runs before consent (unchanged). Check for
  Updates… works from the first launch. ~~IN-BATCH FORK (the implementer proposes, the
  architect rules): the threshold's shape and number…~~ **SUPERSEDED the same day: she asked
  for the cadence to be proposed NOW, with the backup-folder ask joining it (R-13r-12 below)
  — the cadence is THE CALM-ASKS CADENCE below, not a fork.** Her principle governs: opening
  Variorum is calm, and no popup greets a first open.
- **R-13r-12 — THE BACKUP-FOLDER ASK MOVES INTO 13r, beside the update ask (her words,
  2026-10-04: *"propose a cadance for the 'backup folder' iCloud prompt too - I know I said
  13s would do it, but I'd rather that it be done now within this upcoming phase so the two
  popups are handled, being kept in mind that the other exists, together"*).** Today's
  behaviour (read from the code): `ICloudDriveOfferModel.consider(after:)` fires at the FIRST
  automatic backup run (`RootView.swift:248–249`), which happens on the first launch, so the
  modal three-door sheet greets the first open. This SUPERSEDES the timing half of the pre-13x
  design's decision 24 ("the offer at the first backup run"); the offer's copy, doors and
  once-per-store mark are unchanged. Her original note asked for "a popup toast" after some
  use, so the ask becomes an OFFER on the existing status seam (AppSpec §12: offers always
  toast), and the toast's door opens the existing sheet.
- **THE CALM-ASKS CADENCE (proposed by the orchestrator at her request, 2026-10-04; her
  kickoff message RATIFIES it as written unless she amends it there).** One schedule governs
  both asks:
  - **Shared rules.** (1) **Nothing on the first day of use.** A "day of use" is a calendar day
    on which Variorum was opened or brought forward. It is counted on THIS Mac in a LOCAL
    preference, never synced; an app left open across midnight counts the new day the next
    time it becomes active. (2) **Never at the launch moment.** An ask waits until the app has
    been open at least 2 minutes and nothing has been typed for 20 seconds, and never appears
    while a sheet, ceremony or menu is open. (3) **At most one ask per day, and the two never
    share a day.** (4) **Both are always answerable without the popup.** Settings ▸ General
    gains "Check for updates automatically" (mapped onto Sparkle's own setting), and Data
    Safety already has the second-folder door. Answering in Settings retires that ask for
    good. (5) **One home.** A small local scheduler owns the day counter and these rules (Mac
    app, under `Features/`, never `Shared/` — the phone has neither ask). Both asks register
    with it, so a later ask (13s onboarding, for example) joins the same rules instead of
    stacking.
  - **The update ask — from the 3rd day of use,** at the first calm moment that day: Sparkle's
    own permission window ("Check for updates automatically?" — Check Automatically / Don't
    Check). Once answered, never again (Sparkle remembers). Until then no automatic check
    runs; Check for Updates… works from day one.
  - **The backup-folder ask — from the 5th day of use, at least one day after the update ask
    was shown, and only once the library holds writing of the user's own** (a note they made,
    not the seeded welcome content): a quiet OFFER toast — "Keep a copy of your backups in
    iCloud Drive?" with **Set Up…** and **Not Now**. Set Up… opens today's three-door sheet
    (the folder picker needs it). Not Now retires the ask (the existing mark). Ignored (closed
    or timed out with no answer), it returns ONCE more after 7 further days of use, then never.
    A store that already has a second folder is never asked (unchanged).
  - **Why updates first:** during the beta, fixes ship fast, and a friend who never turns on
    automatic checks stays on old builds. The second backup copy matters once there is writing
    worth keeping; until then the automatic local backups beside the library cover everything
    except losing the Mac.
  - **Existing installs:** the day counter starts fresh at the U3 build. A store whose iCloud
    offer is already answered is never asked again. Her daily drive will see the update ask on
    its 3rd day of use after the refresh, and no backup ask if hers is already answered.
  - The numbers (3rd day, 5th day, 2 minutes, 20 seconds, 7 days) are PROVISIONAL, tunable from
    beta use; U3-A logs them as ONE `notes/QUESTIONS.md` entry. A walk test may set the local
    day counter by the container-path `defaults write` on the walk build only — the shipped
    numbers are never shortened.
- **R-13r-13 — THE OUT-OF-DATE SYNC REFUSAL GETS A CALM FACE (her refinement at the U3 kickoff,
  2026-10-04, verbatim: *"One other note and refinement on the popup schedule - if sync doesn't
  work because your version is out of date, a calm message should say so as well."*).** The fact,
  read from the code before recording: `SyncError.schemaLockstepMismatch` (the §12 refusal —
  outbox kept, cursor unmoved, by design) reaches the sync status face as a GENERIC error today —
  `SyncStatusViews.swift` special-cases keys-locked / rekey-incomplete / payload-crypto /
  not-entitled but not this one, so a beta friend would read the engine's own sentence ("Finish
  the schema update on the lagging side; nothing is lost while paused (SyncSpec §12)") — honest,
  but written for the author. U3-A adds the face-side classification on the established pattern
  (the `isKeysLockedError` precedent, app-side): when the SERVER's marker is AHEAD of the app's,
  the face reads calm and plain — this version of Variorum is older than your account's sync
  format; update to continue syncing; nothing is lost while paused — with the door being **Check
  for Updates…** (the U2 channel; the door renders only where the updater is live, P-2). The
  other direction (app ahead of server — her own pre-deploy state under R-13r-7) keeps today's
  quiet generic face: no friend can reach it (the §12 choreography deploys the mirror before any
  release ships). **Zero `Sync/` expected: the classification lands in the face, never the
  engine; the engine's error text stands. Any `Sync/` line stops for the rider.** Pinned by a
  *[removed for publication]*
  walk installs never sign into sync).
- **R-13r-14 — THE FIELD GUIDE'S BACKUPS COVERAGE GAINS THE CHOOSE-A-BACKUP-FOLDER DOOR (her
  refinement at the U3 kickoff, 2026-10-04, verbatim: *"And if the user guide needs an updated
  backups session reflecting where you can choose a backup folder (not sure if we already have
  that in the field guide or not), add that."*).** The fact, checked before recording: it does
  NOT have it — the guide's backups coverage is custody-shaped only (copy §7 / `PostureCopy`'s
  "what opens a backup" sentences); no lesson teaches Settings ▸ Data Safety's "A second folder"
  door. U3-A adds a short backups passage saying where backups live automatically and that a
  second folder of your choosing (iCloud Drive among them) can be picked in Settings ▸ Data
  Safety — speaking the same language as R-13r-12's offer toast, which opens the same sheet.
  Placement (a passage in an existing lesson vs. a short lesson of its own) is the implementer's
  to propose in its record; the lesson-plan contract and `TutorialWalkTests` move with it (P-6).
  **Closeout consequence (the standing rule):** lesson content edits stale the REAL store's
  seeded field guide — the closeout re-seeds it via the product door behind the A1 rail.
*[removed for publication]*
  and run at HER sitting; the U2 walk sheet is the template):** two fresh walk builds through
  the pipeline (0.0.3 → 0.0.4, the stamping build phase now live). Arms: (a) the DMG window
  opens with the drag layout visible (capture); (b) the drag-install, then the FIRST open
  shows NO Sparkle prompt (Gatekeeper's one-time "downloaded from the Internet" question is
  the OS's, expected); (c) What's New appears once after the update and not again on the
  next launch; (d) Check for Updates… installs 0.0.4 over the XPC road, relaunching as
  0.0.4 with the library intact; (e) THE CALM-ASKS CADENCE: on the first day of use NEITHER
  ask appears; with the walk build's local day counter set (container-path `defaults write`,
  walk build only) to day 3 the update ask appears at a calm moment, never at launch; set to
  *[removed for publication]*
  ask's day), Set Up… opens the three-door sheet, Not Now retires it; Settings ▸ General's
  "Check for updates automatically" answers the update ask; (f) Help ▸ Send Feedback… opens a
  pre-filled draft (NOT sent). **W-5 launches by explicit path** (`open ~/Applications/Variorum.app`) —
  *[removed for publication]*
  still holds U2's `SUFeedURL` localhost override; the U3 walk reuses it.
- **R-13r-16 — THE COMBINED PUBLIC-ROAD WALK (her ruling, 2026-10-04, superseding the walk's
  VENUE AND ROAD above; her words verbatim: *"note that I will test out my walk AND the
  download from stargazing.tech at the same time - upload the appropriate build there & I'll
  download it from stargazing.tech on a new computer to see how everything works for a new
  user. I'll let you know if there are any issues"*).** Consequences, recorded:
  *[removed for publication]*
    *[removed for publication]*
    walk-feed mechanics stay recorded for future walks; nothing is cleaned early). This is
    R-13r-8's honestly-recorded gap ("the friends' first installs are the true second-machine
    evidence") made REAL before the first friend.
  - **Sequencing:** after U3-B closes on green suites, the orchestrator runs the REAL
    **0.9.0** through `release.sh` (release mode; the `make-appcast` Keychain read is the one
    her-adjacent moment) and publishes it per R-13r-15 — DMG to `dl.stargazing.tech` first,
    verified reachable, then the appcast + the `/variorum` page's data file, push — BEFORE
    her sitting. The update leg's **0.9.1** is built and published the same way, so
    Check for Updates… exercises the PUBLIC feed end to end: NO feed override exists anywhere
    in this walk. After the walk the page's data file points at the latest 0.9.x.
  - **The no-public-entry HAZARD, RE-DERIVED rather than waived:** its purpose is that HER
    app is never offered a release. Her M3 daily drive is **1.0 (1), PRE-SPARKLE** (the U2
    walk's measured fact — no update machinery exists in it), so a public entry cannot reach
    it; the closeout refresh then hands her a stamped build whose commit count exceeds any
    0.9.x entry's, and Sparkle stays quiet (R-13r-7). The letter is satisfied the day any
    build of hers can check the feed at all.
  - **The PRE-LADDER publish is accepted at her word, with the fence stated:** the page stays
    unlisted/pending and NO LINK goes to friends until the ladder and closeout are done; a
    ladder-driven fix ships as the next 0.9.x through the same road, and her new computer's
    install SELF-UPDATES to it — a further live proof, not a cost.
  - **The arms re-map onto the public road:** (a) the DMG window's drag layout — on the
    DOWNLOADED DMG; (b) the drag-install's first open shows NO Sparkle prompt (the OS's
    one-time question expected) and day 1 of use shows NEITHER ask; (c) What's New appears
    once after the 0.9.0 → 0.9.1 update, not again on relaunch; (d) Check for Updates…
    installs 0.9.1 over the XPC road FROM THE PUBLIC FEED, library intact; (e) the cadence's
    day-counter arms via container-path `defaults write` on the new computer (every line a
    copyable block; shipped numbers never shorten); (f) Help ▸ Send Feedback… opens the
    pre-filled draft. New-user extras now in reach: the fresh store's field guide carries
    R-13r-14's backups passage for her to read in place.
  - **U3-B stages the walk sheet to THIS shape** (its brief carries this bullet), and the
    orchestrator PRE-READS `~/dev/stargazing.tech`'s release runbook before her sitting so
    any credential/tooling need surfaces early (R-13r-15 (3): such a need pauses for her,
    never improvises).
  - Her reports from the new computer are findings — recorded verbatim, routed per the
    standing rule.
- **THE HAZARDS U2 HANDED FORWARD (binding):** no PUBLIC appcast entry may exist until U3's
  stamping is in HER hand-copied `/Applications` build (her daily drive carries build 1 until
  then, and it would be offered the release). The pipeline passes the stamp as command-line
  overrides and `verify-export.sh --expect-version/--expect-build` asserts it — U3's build
  phase writes the same `git rev-list --count HEAD`, so keep the assertion. Release notes plug
  in as `Variorum-<version>.html|md` beside the DMG in the feed directory.
- **SIZING — RULED BY HER (2026-10-04): U3 runs as TWO SUB-PHASES the orchestrator runs in
  order, under ONE acceptance walk** (her words: *"I'll run U3 with an orchestrator, so there can
  be two subphases that the orchestrator runs"*). **U3-A — the release experience and the calm
  asks:** R-13r-6's stamping build phase + MARKETING_VERSION 0.9.0; the one release-notes source
  feeding What's New (shown once per version change + Help ▸ What's New) and the appcast;
  R-13r-10's self-explaining DMG window; THE CALM-ASKS CADENCE for both asks (R-13r-11 + R-13r-12)
  with Settings ▸ General's update checkbox; R-13r-13's calm out-of-date sync face (the Check for
  Updates… door); R-13r-14's field-guide backups passage (the second-folder door taught — the
  closeout's re-seed duty fires). **U3-B — support & diagnostics:** the MetricKit
  opt-in (LOCAL, provably OFF), Diagnostics with payloads verbatim and a per-report Send, Help ▸
  Send Feedback…. U3-B's one in-batch fork stays: the Settings placement of the opt-in +
  Diagnostics (the implementer proposes, the architect rules). Each sub-phase is one fresh
  `opus-implementer` session with its own per-piece commits; the orchestrator verifies each by
  spot-check; the ONE walk runs after U3-B, then the Fable ladder over U1–U3.

### U4 — The accessibility pass

> **DEFERRED POST-LAUNCH AT HER WORD (2026-10-04, the 13i family-close sitting: "I won't be doing
> accessibility before launch"):** this unit does NOT run in the pre-launch 13r; the phase closes
> at U3. The scope below is KEPT INTACT as the post-🚀 unit's brief (the KnownIssues whole-app
> accessibility row carries the recorded decision; the audits' P1/P3 rider still binds whenever it
> runs).

**Scope (the row's letter):** the custom decoration language — take cards, seams, chips (membership,
tags), the ⑂ badge, ordinals, the ceremony sheets' custom surfaces (the ✂ overlay), the sidebar's
terminal-idiom rows — VoiceOver labels/roles/values + keyboard focus-order sanity; native controls
come mostly free. **Build:** accessibility attributes where audits/VO find gaps; XCUITest
`performAccessibilityAudit` suites over the key surfaces (Write · Takes · the shelf · Library · a
ceremony sheet · Settings), scoped so audits never force realization of virtualized rows (P1/P3
bind). **Acceptance:** the audit suites green + a captured VoiceOver walk (VO through a note with a
fan: cards announce, chips speak, the ceremony's arrangement row is operable); her spot-check
invited. **Trap:** decorations are overlays (P-8) — a11y work must not reintroduce rendering
attributes on the live editor.

## ENVIRONMENT TRAPS (the standing core + this phase's own)

Standing (bind verbatim): instance checks `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate
by PATH; real-store instances by STORE, never quit/kill one; no Release builds or `/Applications`
refreshes while one lives; `xcodebuild build-for-testing` compiles without the runner; Mac tests
from `App/Variorum/`, suite-level `-only-testing`, confirm the "Test run with N tests" line and read
`skipped:` lines; zsh `pipestatus`; NEVER a custom build configuration (the 4G trap: SPM builds
RELEASE under any config not literally "Debug"); suites beside a live session flash windows — prefer
zero-instance windows; backups WAL-safe with UTC names, ALWAYS before touching the real store (the
A1 rail); drills need unlocked + author-free + own `caffeinate -d`; screenshots in gitignored dirs;
never `git checkout` over uncommitted work; never force-push. **13r's own:** update testing NEVER
against `/Applications` or the real store — scratch installs in the test account's `~/Applications`
with a defaults feed override; signing/entitlement changes get CLEAN builds before any codesign
verification (stale DerivedData lies); the Developer ID export is Release = real store — it runs
ONLY at zero-instance windows and its first real launch is the U1 drill behind the A1 rail; the
fresh-user-account walk uses fast user switching (her session's app QUIT first — two instances of
one bundle id confuse the discipline even across stores); Sparkle's SPM resolve pins the exact
version (2.10.0); the stamping build phase must run BEFORE code signing or the seal breaks; never
commit the notarytool profile name's secrets, the API key file, or any EdDSA export — the key lives
in the Keychain and her password manager ONLY. **TOOLCHAIN MOVED MID-SITTING (2026-10-04, her
report: an Xcode update "required post upgrade to golden gate mac os" is installing):** at the
orchestrator's pre-update read the machine was macOS 27.0 (26A428) / Xcode 26.3 (17C519),
`xcode-select` at `/Applications/Xcode.app`; the orchestrator RE-READS both versions before the U1
spawn and every unit brief carries the then-current pair. Any odd build/codesign failure in this
phase checks the toolchain FIRST (her own instruction): `xcodebuild -version`, first-launch
component installs, the license (hers to accept if asked), `xcode-select -p` still pointing at the
updated app. A changed Xcode version re-opens nothing ruled — it is an environment fact to record
(CLAUDE.md's environment line updates when the final pair is verified). **DIAGNOSED SAME SITTING:**
her update run had installed CLT 27.0 only (Software Update carries macOS + CLT, never the Xcode
app); the on-disk Xcode stayed 26.3 and the OS now REFUSES its GUI launch (Launch Services -10664,
the compatibility gate; her Spotlight shows the prohibitory icon) while `xcodebuild` still runs.
macOS 27.0.1 (26A434) was offered by Software Update (listed AVAILABLE — the orchestrator's
"downloaded" read overstated; her correction stands: *"i haven't downloaded 27.0.1 so I won't be
doing that right now"* — the point update is DEFERRED at her word, an open environment item, not
13r's). Noted as an unblock option: HER HANDS steps 1–2 need NO Xcode GUI (portal + Keychain
Access CSR for the cert, the profile downloads in the browser, notarytool is CLI).
**RESOLVED SAME SITTING, her hands:** she installed the new Xcode from the App Store WITHOUT the
27.0.1 restart, opened it, components installed, and Settings ▸ Accounts shows the NEW email —
the stale-email check passed with it. **THE FINAL PAIR, re-pinned by the orchestrator and binding
for every unit brief: macOS 27.0 (26A428) / Xcode 27.0 (27A266a)**, `xcode-select` at
`/Applications/Xcode.app`, `-checkFirstLaunchStatus` OK; CLAUDE.md's environment line updated in
the same commit. Xcode 27 is a new MAJOR mid-phase: U1's first act includes a clean
`swift build` + a Mac build so any toolchain breakage surfaces before real work, and any odd
failure checks the toolchain first (her standing instruction above).

## THE LADDER

After U4: ONE `fable-reviewer` over the combined diff, `notes/REVIEW_PROMPT.md` VERBATIM, zero
framing. Cross-model flow (Opus implementers): findings to the implementer verbatim → agree/dispute
→ the REVIEWER makes the final call and implements its confirmed findings itself → suite green →
implementer sanity pass. Round 2 re-reviews; new BLOCKER/MAJOR ⇒ round 3; cap three. Every finding
gets a written disposition here. The hallucination guard binds: traced mechanisms, red-on-old pins
for bug-class fixes, hollow findings dismissed as such.

## RECORDS & CLOSEOUT DUTIES

Per-unit records in this file (LIVE STATUS from the first commit; DONE(hash)/IN-PROGRESS/PENDING
discipline). At close: the KnownIssues keychain row resolved (U1); the master plan's table + pointer
+ closeout paragraph (+ archive rolls); **zero canon deltas expected** (distribution changes no
product behavior — if one arises it lands only as she rules it); **MOBILE PARITY LINE** expected
"nothing mobile-visible", with TWO candidate rows named for the ledger rather than silently dropped
(the phone's crash-report opt-in face; the phone's What's New at the App Store road); the author
handoff `notes/handoffs/phase-13r-handoff.md` with her checklist on top — **which IS the friends-beta
checklist** (site pages live per the brief · 0.9.0 through the pipeline · the download link to
friends · the support mailbox watched); the install refresh at the end (her tip build gains the
stamping too); **the field-guide re-seed behind the A1 rail** (R-13r-14's lesson edit stales the
REAL store's seeded guide — re-seed via the product door at the refresh window, the standing
closeout rule); memory updated. Marker stays 9; zero `Sync/` expected — any `Sync/` line stops for
the rider.

---

## LIVE STATUS (RESUMED 2026-10-04 — the orchestrator's resume record)

**WHAT IS DONE (all pushed):** the kickoff sitting whole — preflight, rulings R-13r-1…9, this plan
file (`dc0d478f`), the 13y closeout-ritual housekeeping + the 13r row moved back + the pointer
(`7f021d22`), the site-agent brief + #145(a)'s ruling (`79a89556`). Zero code written; zero unit
opened; the working tree was left clean.

**THE RESUME RECORD (2026-10-04, the fresh orchestrator; resume steps 1–2 executed):**
- **Step 1 — preflight COMPLETE:** this file in full; CLAUDE.md + the auto-loaded canon; the
  master plan (pointer: 13i-e closed 2026-10-03, 13r is hers to kick off — this invocation is
  that word; the 17y kickoff message carries her sequencing verbatim: *"a brief pause and
  complete 13r, then run this phase"*); KnownIssues end to end (the keychain-access-groups row
  24 is 13r's, and P15 — the key-in-error-description exfiltration path the 17 file flagged
  against crash reporting — is FIXED at 17b with redaction pins, so U3's trust surface starts
  from a closed road); QUESTIONS (#145(a) ruled at this phase's own sitting; #139(a) rides this
  phase's build; #146–#179 all dispositioned — nothing open gates 13r; her carried ratify
  bundle #117–#135 stands untouched); `PhaseSizingGuidance.md`; the resiliency protocol; the
  13y checklist §10; the site brief; the 2026-10-04 privacy-policy brief (it already promises
  "Crash reporting, when it ships (13r), will be opt-in" — U3's copy aligns with it).
- **Step 2 — history check CLEAN:** tree clean, `main` = `origin/main` at `a627434a`; no round
  RUNNING. What ran since the pause (18l-c · 18m · 18n-interim · 18o · 18k tails · the 13i
  family a–e with THREE deployed lockstep events · 17y a–l · phase 19 opened · brand/launch
  content) is all closed and harmless to 13r exactly as predicted (nothing of 13r existed;
  commit-count build numbers only rose). **One live-state delta recorded, not a ruling change:
  the schema marker is 12 today (13i-a 9→10, 13i-c 10→11, 13i-e 11→12, each deployed at her
  window), so this plan's "marker stays 9" closes as "marker UNCHANGED (12 at resume)" — the
  intent (zero schema, zero `Sync/`) binds as written.**
- **Machine facts RE-VERIFIED at resume (unchanged from the sitting):** exactly ONE codesigning
  *[removed for publication]*
  one macOS profile is "Mac Team Provisioning Profile: *" (exp 2027-08-30) — NO Developer ID
  cert, NO Developer ID profile. HER HANDS steps 1–2 are genuinely still owed and open U1.
- **Step 3 ANSWERED by her at the resume sitting (2026-10-04, the question tool), then
  CORRECTED by her the same sitting** (*"I shouldn't have confirmed the URL's fully"* — she
  brought the site agent's note for approval). **THE FINAL URL SET, approved by the
  orchestrator under the R-13r-2 mandate ("adjust freely, report the final URLs back"):**
  - **Appcast (THE BAKED URL, unchanged from the brief):**
    `https://stargazing.tech/variorum/appcast.xml`, served no-cache via a `_headers` file —
    exactly what U2 bakes as `SUFeedURL`.
  - **DMGs (CHANGED from the brief's proposal):**
    `https://dl.stargazing.tech/variorum/Variorum-<version>.dmg` — an R2 bucket on a
    subdomain, no Worker. **Approved on the mechanism:** the enclosure URL lives inside each
    appcast ENTRY (the release pipeline writes it; `generate_appcast`'s download-url-prefix),
    never inside the app, so the host can move later without breaking any install; the
    download's authenticity rides Sparkle's EdDSA signature + Apple's code signing, not the
    host; HTTPS holds on the subdomain (ATS satisfied). The Worker-route alternative is
    declined as needless. **One rider reported back:** a published DMG URL is IMMUTABLE once
    an appcast entry references it — moving/renaming a published DMG breaks that release's
    entry until the appcast is regenerated.
  - **Download page:** `/variorum`, unlisted — DMG link, version, "macOS 26 or later, Apple
    silicon" (the brief's item 2, as proposed).
  - The site brief IS CARRIED; the mailbox `support@stargazing.tech` does NOT exist yet — an
    OPEN AUTHOR ITEM carried to the closeout's beta checklist (needed before the beta's first
    install, not before U1; U3 bakes the address as ruled, R-13r-3/9).
- **Step 4 — U1 opens with HER HANDS steps 1–2** (walked this sitting), then the U1
  `opus-implementer` spawns briefed from this file's U1 section + environment traps.
- **U4 DEFERRAL ADOPTED (her decision, recorded out-of-band at `47d23955` the same sitting:
  "I won't be doing accessibility before launch"):** the phase runs U1 → U2 → U3; the ladder
  runs over the combined U1–U3 diff; the phase CLOSES AT U3. The U4 brief stays intact in this
  file as the post-🚀 unit's brief; KnownIssues row 67 carries the decision.
- **TWO AUTHOR REPORTS AT THE RESUME SITTING (2026-10-04, verbatim-faithful; recorded before
  *[removed for publication]*
  *[removed for publication]*
  reflected, but if it looks stale on this computer I'll have to fix and update that somehow…
  let me know if I need to log out and in somehow to update this stale email before I do this
  developer app identity issue."* The local Apple Development cert indeed still reads
  *[removed for publication]*
  orchestrator's guidance: check Xcode ▸ Settings ▸ Accounts refresh, sign out/in only if it
  errors; certs/profiles/keychain survive a sign-out; the Developer ID cert carries the TEAM
  name, not the email; the Apple ACCOUNT behind iCloud-Keychain custody is the same account
  under a new label — no custody implication). (2) *"I also want to know what I'd have to do to
  reserve the variorum name on the apple ios store… if submitting it would reserve the name,
  then we can submit it too. i don't want someone else taking that name."* — **VERIFIED by a
  read-only Sonnet lookup (2026-10-04):** creating the APP RECORD in App Store Connect (New
  App: platform · name · primary language · bundle ID · SKU) claims the name at creation, NO
  submission needed (Apple's create-an-app-record help documents the uniqueness rule; the
  no-submission-needed half is community-confirmed, not Apple-stated). **No current
  Apple-documented dormancy/reclaim rule could be confirmed** — the old 120/180-day
  reclaim windows are HISTORICAL (community reports say the cap was dropped ~2014); whether
  any clock exists today, and whether a TestFlight upload would affect one, is UNCONFIRMED
  either way. The honest posture: create the record now (it reserves immediately), treat the
  hold as solid-on-community-evidence, ask Apple Developer Support only if certainty matters;
  submitting the unfinished app buys nothing the record doesn't. The act is HERS, adjacent to
  (not inside) 13r's scope; it rides the beta checklist as an optional author item.

**RESUME — the fresh orchestrator's first acts, in order:**
1. Read this file IN FULL (the kickoff section names the rest of the preflight). Do NOT re-open any
   ruling — the sitting settled them; a newfound technical constraint goes to her, per the skill.
2. `git log --oneline -10` + `git status -sb` first: one or more 18 health rounds may have run
   since the pause (`notes/plans/post-13u-health-rounds.md` — 18k → 18l → 18m, 18n flexible).
   Their commits are expected and harmless to 13r (nothing of 13r is built; the build-number
   stamping is commit-count-based, so intervening commits only raise it, which is the safe
   direction). If a round is still RUNNING, stop and coordinate with her before spawning anything.
3. Ask her whether the site-agent brief has gone out and whether the appcast URL / mailbox have
   answers yet (`notes/stargazing-13r-distribution-brief.md`) — U2 bakes the URL, so the earlier
   this settles the better; U1 does not wait on it.
4. Open **U1 with HER HANDS steps 1–2** (the HER HANDS section): walk her through the portal steps
   live (Developer ID Application cert · the Developer ID provisioning profile · the notarytool
   credential), then spawn U1's `opus-implementer` briefed ONLY from this file's U1 section +
   environment traps.

- **HER HANDS PROGRESS (2026-10-04, the resume sitting):** step 1's CERTIFICATE done and
  *[removed for publication]*
  *[removed for publication]*
  **step 2 DONE** — the notarytool credential `VariorumNotary` validated and saved to her
  *[removed for publication]*
  hers to move out of ~/Downloads — never into the repo). **STEP 1 COMPLETE (2026-10-04): the
  Developer ID provisioning profile is minted, installed and ORCHESTRATOR-VERIFIED.** Her road,
  recorded: no explicit App ID existed (the Mac app had only ever signed against the
  team-wildcard development profile; the portal listed only Fragments' three), so she
  registered `io.lduarte.Variorum` (description "Variorum Mac", explicit) — the portal's
  capability list did NOT offer Keychain Sharing (searched; empty), registered without it on
  the orchestrator's call, and the call is proven right below. Profile "Variorum Developer
  ID", downloaded to `~/Downloads/Variorum_Developer_ID.provisionprofile` and
  double-click-installed (Device Management shows it). **Decoded facts (`security cms -D`):**
  *[removed for publication]*
  BOTH groups exactly as the sitting's external-facts bullet predicted;
  *[removed for publication]*
  *[removed for publication]*
  byte-exact; `ProvisionsAllDevices` = true; expires 2044-09-29. The U1 drill's static leg
  re-checks all of it ON THE EXPORT.
- **HER HANDS steps 1–2 COMPLETE. Step 3 (EdDSA minting) waits for U2's start; the mailbox
  rides the beta checklist. The profile FILE may be committed if the export road wants it
  versioned (it is NOT a secret — it ships inside every app bundle as
  `embedded.provisionprofile`); the `.p8` and any EdDSA material NEVER.**
- **U1 — OPEN (2026-10-04; the implementer spawns from this record).** Its brief: this file's
  U1 section + ENVIRONMENT TRAPS + this LIVE STATUS (the toolchain pair, the profile and
  credential facts above) + the resiliency protocol. First act: a clean `swift build` + a Mac
  build to surface any Xcode-27 breakage. The LIVE drill leg (b) is AUTHOR-GATED — the
  implementer builds the road and the static leg, STAGES the live drill (A1 rail
  instructions ready), then stops and reports; the orchestrator coordinates her launch.
- **THE TOOLCHAIN-GATE ROUTING ADJUDICATED (the orchestrator, 2026-10-04, post-compaction — the
  U1 RECORD's routing question; TEXTKIT2_NOTES re-read first per the editor-seam rule): OPTION
  (a), REFINED.** The `PaneSurface.swift:1076` break is a TOOLCHAIN compile error, not a TK2
  behavior shift (no TK2 API implicated; the OS build is unchanged at 26A428) — nothing ruled
  re-opens. (1) U1's implementer LANDS the one-line use-site fix as its OWN commit (the probe's
  shape — same value on both arms), flagged editor-seam for 13r's Fable ladder; the
  conformance-isolation alternative (c) is DECLINED (wider blast radius on a cross-platform
  Theme type; both sessions agree); then pieces 2–4 as designed. (2) The 28 test/mobile errors
  are **19a** — the 19 ledger's FIRST entry (opened by this orchestrator; scope, rules, cast
  and acceptance live there): a MECHANICAL migration, assertions byte-preserved
  (`FurnitureConvergenceRepairTests` is sync-convergence protection — its Opus cold review
  explicitly checks nothing weakened), run AFTER U1's session ends and BEFORE U2 spawns
  (U2/U3's pins and the ladder's "suite green" need the restored base; U1's static drill does
  not). 19a's acceptance includes the TK2 point-release tripwire suites green under Xcode 27 —
  the first suite run on the new major IS the SDK-shift census — and `PaneSurfaceTests`' five
  `PaneDecoration.resolve` pins, which PROVE the U1 line behavior-preserving. (3) Her LIVE
  drill waits on none of 19a — it can run as soon as U1 stages it.
- **U1 VERIFIED BY THE ORCHESTRATOR (2026-10-04, the acceptance walk's static half):** the five
  resumed commits spot-checked (the one-line fix diff at `a8691989` is exactly the authorized
  shape, editor-seam flagged); the static drill RE-RUN by the orchestrator's own hands against
  run 2's export with the daily-drive compare — **VERDICT: PASS 35/35**, independently
  reproducing the implementer's result (both groups in order, the profile authorizing by the
  team wildcard, groups byte-identical to her `/Applications` build, Gatekeeper's expected
  unnotarized-Developer-ID read). **U1 now waits ONLY on her LIVE drill** (the staged checklist
  at this record's tail: the orchestrator runs the [O] steps, she runs the two launches).
  Surfaced, not acted: run 1's leftover real-store bundles (named in the record; the
  implementer's `rm` was harness-stopped, so removal is held for her word — recommended before
  the drill window so exactly ONE drill bundle exists). DISPOSITIONED: the export stays
  UNIVERSAL (x86_64+arm64) — the download page's "Apple silicon" line remains true (it
  understates); revisit only if U2's DMG size argues. NOTED for the closeout's debris sweep,
  untouched: a stray older real-store Release build under
  `~/Library/Developer/Xcode/DerivedData/Variorum-dnpxwqhpxdqrdjbunktnzoahckpd/`. **19a
  SPAWNED** (the adjudicated sequencing: after U1's session, before U2); its suites run at
  quiet windows and her drill OUTRANKS it if both want the machine.
- **HER ANSWERS AT THE DRILL SITTING (2026-10-04, verbatim-faithful):** 19a's session-opened
  birth RATIFIED (*"that's fine on 19a being opened by you - the ledger never needed to say
  that it would be author filled in the first place, the 17 series was also used by sessions
  whenever they needed a place to put an issue"* — recorded in the 19a entry too); run-1
  leftovers *"go ahead and delete them"* — DONE at her word (the export and xcarchive bundles
  removed; run-1 logs kept until the closeout sweep); the universal binary *"that's fine i
  think"* — the disposition stands; the stray DerivedData Release build *"you can remove
  that excess release build"* — DONE (the app bundle removed, dSYM left). *"i'm ready for
  the drill"* — the LIVE drill runs this sitting; verdict lands in the U1 RECORD.
- **U1 — CLOSED (2026-10-04, the drill sitting): the LIVE drill PASSED all five arms** (the
  VERDICT at the U1 RECORD's tail; the KnownIssues row-24 flip this PASS authorizes rides the
  phase close, per the checklist's own sentence).
- **THE SITE-SIDE REPORT (2026-10-04, carried by her from the stargazing.tech agent — recorded
  the same sitting; U2's brief MUST carry this bullet):** all three brief items COMPLETE and
  verified live. **(1) URLs LOCKED exactly as adjudicated** — appcast
  `https://stargazing.tech/variorum/appcast.xml` (no-cache, must-revalidate; U2 bakes it);
  DMGs `https://dl.stargazing.tech/variorum/Variorum-<version>.dmg` (R2 custom domain, HTTPS
  ≥TLS1.2/ATS, `application/x-apple-diskimage`, `public, max-age=31536000, immutable`); the
  immutability rider ADOPTED as their publish-and-leave rule. **NEW BINDING FACTS for U2's
  pipeline:** the DMG filename stays `Variorum-<version>.dmg` EXACTLY (their per-IP rate
  limit — 10 req/10 s, 429-verified — keys on that prefix); each appcast `<enclosure url>`
  must be exactly the dl.stargazing.tech URL with `length` = the DMG's byte size
  (`generate_appcast` + download-url-prefix satisfies both); **publish order is DMG first,
  verified reachable, THEN appcast** — the release runbook U2 writes must emit the handoff
  shape: SHE carries `appcast.xml` + the DMG to the site repo, whose agent runs their
  `notes/variorum-releases.md`. The public rate limit never touches the R-13r-8 walk (local
  feed override, locally served files). **(2) The download page** `/variorum` is live:
  unlisted + noindex, version + DMG button + "Requires macOS 26 or later, Apple silicon" +
  the support mailto; a PENDING state shows until the first release; it reads version/URL
  from one per-release data file (page copy is HERS, post-launch-changeable — rides her
  items). **(3) THE MAILBOX IS LIVE — `support@stargazing.tech` lands in her own Mail inbox,
  her test message received** (iCloud+ custom domain; MX/SPF/DKIM/DMARC in place). This
  SUPERSEDES every "mailbox does NOT exist yet" line above and CLOSES HER HANDS step 4 and
  the beta-checklist's mailbox item — U3's Help ▸ Send Feedback… and the crash-report flow
  now target a real inbox. Site-side open items: the live no-cache header check at the first
  release; her beta-page copy.
- **19a MID-RUN ADJUDICATION (the orchestrator, 2026-10-04):** the 19a acceptance line claiming
  `PaneSurfaceTests`' five resolve pins "PROVE the U1 line behavior-preserving" is CORRECTED —
  the implementer found they do NOT discriminate it (non-nil tokens, relative compares; honest
  report, routed up rather than claimed). Its throwaway absolute probe read the shipped values
  on BOTH arms, so the equivalence itself holds. AUTHORIZED as a scoped exception to 19a's
  no-new-assertions rule: ONE committed pin asserting `PaneDecoration.resolve`'s ABSOLUTE rest
  values on both arms (nil tokens → the gray-0.25 stroke at 0.5 width; voiced tokens → clear),
  named as the Xcode-27 isolated-conformance fix's tripwire. 13r's ladder reviews the fix;
  19a's cold review sees the pin. The implementer also records, in one line, the core-count
  delta vs the 13i-e closeout baseline (2174/244 vs 2173/244 — name where the +1 came from).
- **19a AT REVIEW-PENDING (2026-10-04, the implementer's stop — verified by spot-check: diff
  scope 21 files exact, tree clean, all pushed through `574ea6a8`):** every target compiles
  and runs green under Xcode 27 (core 2174/244 full; the fixed files' 48 suites 286 green;
  the authorized pin landed WITH a mutation check — red 15-issue under swapped arms, the only
  failure; mobile builds; the +1 explained as `6b1eefaf`'s post-close pin). **THE SDK-SHIFT
  CENSUS ANSWER:** the TK2 tripwire suites ran green at a zero-instance window, 41 tests, and
  the four #154(b) known-issue measurements read EXACTLY the recorded 27.0 values (−10.0 pt
  Terminal / −20.0 pt Study) — **no TK2 geometry shift on the Xcode 27 SDK.** **The
  vacuous-#expect question SETTLED by the orchestrator's own probe (the implementer's 2-minute
  check, run and deleted):** a deliberately FALSE expectation of the warned call shape in the
  same target FAILED with full expansion detail — the shape is REAL, the Xcode-27 "unused
  result" warning inside the Testing macro expansion is cosmetic; NO sweep entry opens; the
  19a record's NOTICED row carries this disposition. The Opus cold review spawns next; U2
  spawns at the entry's close. **[WITHDRAWN SAME DAY — the settlement above was WRONG. The
  19a round-1 review proved the warned line vacuous, and the orchestrator CONFIRMED it by
  the decisive check (the false `.tag("")` stayed GREEN): the settling probe had substituted
  `.legacyProfile` for the trigger spelling `.tag`, which changed overload resolution. The
  binding record is the 19a ROUND 1 section of the 19 ledger (F1's disposition + the
  exact-spelling lesson + the census rule); finding 2 there opened 19b (the mobile
  test-target census, ~61 sites). Kept un-deleted so the error and its correction both
  stand.]**
- **19b's after-U2 scheduling RATIFIED by her (2026-10-04, verbatim): *"yeah, that's fine for
  19b to run later."*** The queue stands: 19a round 2 → 19a closes → U2 → 19b at a seam.
- **19a CLOSED (2026-10-04, round 2 clean: no BLOCKER/MAJOR — the record is the 19 ledger's
  ROUND 2 section).** R2-1 completed the settlement lesson (the IMPORT GRAPH, not only the
  spelling, decides the `#expect` overload — settlements mutate IN PLACE in the real target);
  R2-2 amended 19b/19c (the mobile vacuous-check owned); both queued at the post-U2 seam as
  she ratified. *(A record slip found while flipping this state: an earlier bullet
  replacement had silently dropped the "U2 — NOT STARTED" state line; restored here as U2 —
  OPEN.)*
- **U2 — OPEN (2026-10-04; the implementer spawns from this record).** Its brief: this file's
  U2 section + ENVIRONMENT TRAPS + this LIVE STATUS (the toolchain pair, the SITE-SIDE
  REPORT bullet's LOCKED URLs and pipeline facts, the U1 RECORD's reusable export road) +
  the resiliency protocol. FIRST PIECE then PAUSE: Sparkle 2.10.0 via SPM (Mac target ONLY)
  + the signed command-line tools obtained + the minting commands staged — HER HANDS step 3
  (EdDSA minting) happens at that pause, the orchestrator carrying the commands to her; the
  WALK (R-13r-8) is AUTHOR-GATED: staged by the session, never run by it. **WALK-PREP opened
  this sitting, her hands:** the fresh macOS user account (Standard, NO Apple ID sign-in,
  fast user switching in the Menu Bar) — steps given. **DONE (her report, same sitting): the
  *[removed for publication]*
  its password is hers alone and stays out of the repo.** One wrinkle she hit, resolved: the
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  toggle to be enabled on the next visit (per-user, no admin expected). The walk checklist
  assumes the log-out road works everywhere.
- **HER WORD AT THE POST-COMPACTION RESUME (2026-10-04, verbatim-faithful; the orchestrator
  re-oriented from the handoff's SECOND edition, found the U2 implementer live mid-piece-5,
  and messaged it contact-only — no twin):** *"plan to proceed with 19b / 19c - don't pause
  chat with a question, I'll send a message proactively when I see U2 coming to an end if
  I'm ready. Feel free to use the computer as needed for testing - I've stepped away for now
  and will be back for the U2 walk."* So: when the U2 implementer stops with the walk STAGED,
  the orchestrator verifies its pieces by spot-check and spawns **19b without pausing for
  her** (then 19c after 19b closes, each with its per-entry Opus cold review, one agent at a
  time); the machine is free for suite runs while she is away; her proactive message — not an
  orchestrator question — opens the walk sitting, and the walk outranks 19b/19c for the
  machine whenever she is ready.
- **U2 VERIFIED TO THE SEAM (the orchestrator, 2026-10-04, post-report spot-check by its own
  hands):** the implementer stopped at `469d419a` — tree clean, `main` = `origin/main`, zero
  instances. Verified directly: the fence read in source (`UpdateChannel.liveInThisBuild`,
  `#if DEBUG` → false, instantiation-only); the Info.plist's three keys byte-exact (her
  public key, the LOCKED feed URL, launcher ON) with the three absences confirmed; the
  entitlements' variable-form `-spks`/`-spki` pair; the public appcast answering **404**
  (nothing published, as claimed); BOTH walk DMGs stapler-validated + Gatekeeper **ACCEPTED
  (Notarized Developer ID)** with sha256s byte-matching the record; the piece-4 pins RE-RUN
  by the orchestrator — **13 tests / 3 suites GREEN**; the staged W-0…W-10 checklist read in
  full and matching the agreed mechanics (her-session [O] steps, the log-out road, the
  scratch-only container-path override, zero-instance discipline, the two hazard notes
  recorded for U3's sequencing). **U2's code and pipeline are DONE; U2 now waits ONLY on her
  walk sitting — the walk's VERDICT closes it.** Per her resume word, **19b SPAWNS NOW**
  (19c after it closes), one agent at a time, her walk outranking both for the machine.
- **THE AWAY-GAP'S 19 WORK — the record, with ONE DEVIATION OWNED (2026-10-04, at her ask:
  "ensure the docs note the deviation"):** the gap ran **19b** (her word) → **19c** (her
  word) → **19d** — and 19d was NOT in her word's letter: it was born from 19c round 1's
  MAJOR (a silent-`#require` class behind a false clearance sentence, unowned) and the
  orchestrator SPAWNED AND RAN it on its own judgment under the SPIRIT of her away-gap
  authorization ("don't pause chat with a question"), recorded here as the deviation the
  skill requires, never silent. Why it was judged right to run: every 19 entry was
  TEST-SIDE ONLY (zero lines that ship; the per-entry reviewers confirmed nothing under
  `13r-u1/`, `13r-u2/` or `Tools/Release/` newer than base each round), the silent class
  included two custody-drill assertions the 13r ladder's "suite green" would otherwise
  lean on hollowly, and her walk retained right-of-way throughout. **THE REFOCUS
  COMMITMENT, binding from here:** after 19d's round-2 verdict closes it, NO further 19
  letter runs inside 13r — anything new a review surfaces is RECORDED AND QUEUED, not run;
  the phase's own spine (her walk → U3 → the ladder → closeout) is the only work. **Walk
  readiness re-confirmed at this writing:** both walk DMGs in place (stapler-validated +
  Gatekeeper-accepted at the U2 seam check), the W-0…W-10 checklist staged in the U2
  RECORD, zero instances; `walk-feed/` is absent BY DESIGN (it is born at W-0(c), the one
  Keychain step, with her at the machine). **U3 readiness:** its brief inputs are all
  in-plan (the U3 unit section + the U2 RECORD's interface notes — the stamp passed as
  overrides with the export assertion, release notes as `Variorum-<version>.html|md`
  beside the DMG, the two hazard notes: no public appcast entry before U3's stamping is in
  her hand-copied build; her daily drive will see Sparkle's consent prompt once after the
  refresh); U3's implementer spawns the moment her walk closes U2, strictly sequential.
- **TWO AUTHOR REPORTS AT THE WALK SITTING (2026-10-04, verbatim-faithful; recorded
  mid-walk):** (1) **FOR 13s ONBOARDING, her words:** *"make a note for 13s onboarding that
  I don't like the 'choose backups' popup appearing on app open - it ruins the calm feeling
  of opening the app, that can surface after some use as a popup toast."* Routed to 13s
  (first-run onboarding is 13s's scope; the closeout handoff carries this forward).
  (2) **A use-shaped DMG finding, observed live:** at W-3 she did not see the DMG's
  Applications link (it exists — the pipeline writes app + link — but with 13r's
  deliberately clean, art-less DMG it reads as a bare folder icon) and launched the app
  FROM THE MOUNTED DMG; Gatekeeper's notarized-app prompt appeared there and the app ran.
  Friends will do the same. FOR 13s: the DMG background art should carry the
  drag-to-Applications affordance (the standard arrow). WALK CONSEQUENCE, handled in the
  sitting: Sparkle refuses updates from a read-only/temporary location (its source, the U2
  facts), so the walk resumed with quit → the W-6 override written EARLY (the container
  exists after the DMG launch — this also keeps any consent-triggered check off the public
  feed) → the W-4 drag-install → W-5 from `~/Applications`; consent may arrive one launch
  earlier than the sheet's count (the DMG launch set Sparkle's first-launch flag) — the
  acceptance cares that consent is ASKED with no profile option, not its ordinal.
  **(3) A SAME-MACHINE WALK HAZARD, caught by her About screenshot (1.0 (1)):** the drag-install
  landed correctly (`~/Applications/Variorum.app` reads 0.0.1/4829; `spctl` accepted, quarantine
  inherited), but the app she then OPENED was `/Applications/Variorum.app` — HER daily-drive
  build (1.0 (1), pre-Sparkle, no update door), visible to every account because `/Applications`
  *[removed for publication]*
  *[removed for publication]*
  this-Mac-only hazard (a friend's Mac has no dev build there), but the walk sheet's W-5 must
  launch by explicit path (`open ~/Applications/Variorum.app`) — the resumed walk does.
  **(4) TWO AUTHOR RULINGS AT THE WALK SITTING (2026-10-04, verbatim-faithful) — both ride
  U3:** **R-13r-10 — THE SELF-EXPLAINING DMG WINDOW, APPROVED:** *"yeah let's do this one -
  that's what I'm talking about as a standard experience … approved"* — the DMG window opens
  with the app icon and the Applications link in FIXED positions and a plain "drag here"
  arrow or label between them; functional layout only (plain `hdiutil` + scripted Finder
  window settings, no new dependency); the branded background art stays 13s's. (The
  companion in-app "running from the disk image" notice was offered too; she approved the
  DMG window only — the notice is NOT ruled and is not built.) **R-13r-11 — NO POPUP AT
  FIRST OPEN: SPARKLE'S CONSENT IS DEFERRED:** *"again, I don't want the user experience to
  start with a popup. please change things so that this popup shows up after they've been
  using the app."* This supersedes U2's "Sparkle asks on the second launch" stock flow: U3
  defers the "Check for updates automatically?" prompt until after real use (mechanism:
  Sparkle's updater delegate declines the early permission prompt, and the channel asks
  later; Check for Updates… works throughout). The exact "after use" threshold is
  PROVISIONAL, the implementer proposes and the architect rules. It pairs with her 13s
  backups-popup note above as one principle: **opening Variorum is calm — no popup greets a
  first open.** **(5) Walk facts, step by step:** the `~/Applications` copy's first open
  showed the notarized "downloaded from the Internet" question (expected — each newly
  quarantined copy asks once; W2 ✔); consent was ASKED with no profile option (W6 ✔); About
  read 0.0.1 and Check for Updates… was present (W4/W5 ✔); the first Check returned
  "Update Error" because the W-6 feed override had not been written (her transcript has no
  `defaults read` line; the server log shows no request from the app), so Sparkle correctly
  asked the BAKED public feed, which 404s pre-release. This is correct behaviour, not a
  defect. The walk resumes with the override written and verified.
  The model-seat note: the Fable seat hit repeated safeguard stops mid-walk; at her switch
  the walk continues on Opus 5.5 (her call), the rest of the phase returns to a Fable
  orchestrator via her next kickoff.
- **U2 — CLOSED (2026-10-04, the walk sitting): the walk PASSED every arm** (the VERDICT at the
  *[removed for publication]*
  her return leg clean). Her two walk rulings (R-13r-10, R-13r-11) are written into the U3
  section as the unit's amendment.
- **THE SEAT HANDS BACK TO FABLE:** the walk was finished on Opus 5.5 at her call (the Fable
  seat hit repeated safeguard stops mid-walk); she kicks off a FRESH Fable orchestrator for
  U3, the ladder and the closeout from the handoff's THIRD edition
  (`notes/plans/phase-13r-orchestrator-handoff.md`).
- **THE FRESH FABLE SEAT (2026-10-04, her `/architect-phase 13r` kickoff from the handoff's
  THIRD edition):** preflight run per the skill (the handoff, this file IN FULL, CLAUDE.md +
  canon, the master plan, KnownIssues, the resiliency protocol; QUESTIONS + sizing guidance in
  the same pass); tree clean at `92f1b51a` = `origin/main`; no agent running. Her kickoff
  RATIFIES the calm-asks cadence as written. **TWO REFINEMENTS arrived with the kickoff and are
  RECORDED AS R-13r-13 (the out-of-date sync refusal's calm face) and R-13r-14 (the field
  guide's backups passage) in the U3 section above — both U3-A's**; the facts under each were
  read from the code before recording (the generic error face today; no second-folder lesson
  today).
  her ask: "we're just answering the questions now so that U3 can run smoothly"):** two
  sub-phases, U3-A then U3-B, under one walk (RULED); THE CALM-ASKS CADENCE written into the U3
  section for both asks (proposed at her request; her kickoff message ratifies it); R-13r-12
  moves the backup-folder ask into 13r from 13s. The only fork left in U3 is U3-B's Settings
  placement of the crash-report opt-in + Diagnostics.
- **R-13r-15 — THE SITE-PUBLISH EXEMPTION: THE FIRST RELEASE GOES ONTO stargazing.tech BY THE
  ORCHESTRATOR'S HANDS (her ruling at the U3 kickoff, 2026-10-04, verbatim: *"after your
  closeoff duties are done, I'm going to want you to go into ~/dev/stargazing.tech and read the
  files / instructions there and put the first updated dmg on there + push, so that people can
  download it from my app. This will be a known exemption to the 'not editing other repos rule'
  - when I have a release ready, I want you to be able to go update the stargazing.tech website
  with it. you can also use a subagent for the purpose if you prefer."*).** Consequences,
  recorded: (1) a STANDING, SCOPED exemption — `~/dev/stargazing.tech` may be entered to
  publish a READY RELEASE, following that repo's own files/instructions (their
  `notes/variorum-releases.md`, per the SITE-SIDE REPORT); the exemption is release-publishing
  only, and Fragments stays hands-off exactly as before. (2) The beta checklist's publish shape
  is SUPERSEDED: "she carries `appcast.xml` + the DMG to the site agent" becomes — after the
  closeout duties (including her `/Applications` refresh carrying the stamping, the standing
  HAZARD's precondition), the orchestrator runs 0.9.0 through `release.sh` (the `make-appcast`
  Keychain read may ask her once — the one her-adjacent moment) and then publishes site-side in
  the LOCKED order: the DMG first to `dl.stargazing.tech` (exact name `Variorum-<version>.dmg`,
  immutable once referenced), verified reachable, THEN the appcast + the `/variorum` page's
  per-release data file, commit + push; `verify-published.sh dmg` and `appcast` close the loop
  from this side. A subagent may carry the site-side legs at the orchestrator's preference.
  (3) Anything the site repo's instructions demand that this machine lacks (credentials, an R2
  upload tool needing her sign-in, GUI steps) PAUSES for her — the exemption opens the repo,
  never her accounts. (4) Nothing publishes before her hand-copied build carries the stamping —
  the hazard binds unchanged; her "after your closeoff duties" sequencing satisfies it by
  construction. The closeout's author handoff (`notes/handoffs/phase-13r-handoff.md`) is
  written to THIS shape.
- **U3-A — OPEN (2026-10-04; the implementer spawns from this record).** Its brief: this file's
  U3 section WITH ITS AMENDMENTS (R-13r-10…14 + THE CALM-ASKS CADENCE + the walk arms + the
  hazards + SIZING — U3-A's scope list is the sizing bullet's) + ENVIRONMENT TRAPS + this LIVE
  STATUS (the toolchain pair macOS 27.0 (26A428) / Xcode 27.0 (27A266a), re-verified at this
  spawn; the SITE-SIDE REPORT's locked URLs; the U2 RECORD's piece-4/piece-5 interface notes) +
  the resiliency protocol. The walk is STAGED only (one walk after U3-B, at her sitting); zero
  `Sync/` (R-13r-13 is face-side; any `Sync/` need stops and reports), zero schema, nothing
  published (the public appcast stays 404). One architect reading recorded for the implementer:
  What's New "shown once when the version changes" under her no-popup-at-first-open principle
  means a FRESH store records the current version silently and shows nothing — the sheet
  appears only on a version CHANGE from a recorded one (the walk's arms (b)/(c) read exactly
  this way); pin it.
- **U3-A VERIFIED BY THE ORCHESTRATOR (2026-10-04, the seam spot-check by its own hands):** tree
  clean at `ec2ac9fb` = origin; the whole-diff scope check shows ZERO `Sources/VariorumCore/Sync/`
  and ZERO mobile-target lines; the four new pin suites RE-RUN — **31 tests in 4 suites GREEN,
  no skips** (VersionScheme · SyncOutOfDateFace · WhatsNew · CalmAsks); the Finder-automation
  denial REPRODUCED under the orchestrator's own shell (the probe prints DENIED); QUESTIONS #180
  in place; the U3-A RECORD read in full. **The pre-existing runbook drift is QUEUED as 19e**
  (the parked-ledger rule — the ladder's finals read green modulo that one named red).
  **U3-A's open tail rides the pre-walk staging:** the DMG window's first proof is the
  no-notarization dry run, gated on HER Automation toggle (below).
- **R-13r-6 ADJUDICATED READING (the orchestrator, from the ruling's own letter "0.9.x
  increments per beta release"):** the repo's MARKETING_VERSION increments WITH each beta
  release — the release run's first act is the version-bump commit (release.sh demands a clean
  tree anyway), so her hand-copied tip build's About tracks the latest published 0.9.x. Cosmetic
  either way (Sparkle compares build numbers); recorded so the implementer's flagged question
  has its answer.
- **HER ITEMS BUNDLED FOR THE SITTING (nothing improvised around):** (1) **the Automation
  toggle** — System Settings ▸ Privacy & Security ▸ Automation ▸ Ghostty ▸ Finder → ON; the
  ruled DMG-window road cannot run without it, and `release.sh` refuses at preflight until it is
  on. The moment it is on, the orchestrator runs the no-notarization dry run and captures the
  window (the record's piece-5 command). (2) **the 0.9.0 release notes** — `App/Variorum/
  Variorum/Features/WhatsNew/ReleaseNotes-0.9.0.md` is a functional draft; it goes PUBLIC at the
  release run, so it is hers to rewrite or okay as-is. 0.9.1's notes are the orchestrator's to
  draft functional-honest at the release run (her look invited). (3) QUESTIONS #180's
  PROVISIONALs ride her ordinary ratify cadence, nothing gating.
- **MOBILE PARITY accumulator for the closeout:** the calm out-of-date sync sentence reaches the
  PHONE (the face is `Shared/`; no door — its updates are the App Store's) — joins the two
  candidate rows the closeout duties already name.
- **U3-B — OPEN (2026-10-04; the implementer spawns from this record).** Its brief: the U3
  section's U3-B scope (the SIZING bullet's list — the MetricKit opt-in LOCAL and provably OFF
  with the injected registration seam; Diagnostics listing payloads VERBATIM with a per-report
  Send; Help ▸ Send Feedback… pre-filled and never auto-sent) + the IN-BATCH FORK protocol (the
  Settings placement of the opt-in + Diagnostics: the implementer builds the placement-free
  half, writes its PROPOSAL in its record, STOPS; the orchestrator rules repo-first and resumes
  it) + R-13r-16's walk shape (U3-B STAGES the walk sheet to the combined public road — the new
  computer, the public feed, 0.9.0 → 0.9.1, U3-A's day-counter recipe, arm (f)) + ENVIRONMENT
  TRAPS + the resiliency protocol. Context it inherits: Settings ▸ General now carries U3-A's
  Updates section; P15 (the key-in-error-description road) is CLOSED since 17b with redaction
  pins; the privacy-policy brief already promises opt-in crash reporting — U3-B's copy aligns.
  Zero `Sync/`, zero schema, zero mobile; nothing published.
- **THE R-13r-16 RUNBOOK PRE-READ — DONE (the orchestrator, 2026-10-04; the R-13r-15 exemption's
  first act, READ-ONLY):** the site repo is `~/dev/stargazing.tech/stargazing-tech/` (an Astro
  site on Cloudflare Workers; note the nested folder — the memory's flat path was stale); the
  runbook `notes/variorum-releases.md` there is complete and settled against this phase's own
  brief ("Settled 2026-10-04 with the Variorum side"): per release, in order — preflight 404 on
  the exact DMG key · `npx wrangler r2 object put variorum-downloads/variorum/Variorum-<v>.dmg
  --remote` with the content-type and immutable cache-control · curl the download · drop the
  pipeline's `appcast.xml` into `public/variorum/` · bump `src/data/variorum.json` (version +
  the full dl URL) · `npm run build && npm run deploy` · the no-cache header check (NEVER yet
  verified live — the first release proves it, the runbook's own note) · the page check ·
  commit + push. **CREDENTIALS: NO GAP** — `wrangler whoami` answers her OAuth token on this
  machine (R2/Workers/deploys covered; DNS/security rules are dashboard-only and NOT needed for
  a release). **The publish road is clear end to end; the ONLY gates left before the sitting
  are HER two bundle items** (the Automation toggle; the 0.9.0 notes rewrite/okay).
- **THE U3-B PLACEMENT FORK RULED (the orchestrator, 2026-10-04, the in-batch rule — the
  implementer proposed, the architect rules; the proposal is the U3-B RECORD's piece 4):
  OPTION A — a TENTH SETTINGS PANE, "Diagnostics", between Data Safety and Acknowledgments,
  exactly as proposed.** The deciding grounds, stated: the brief and the plan themselves name
  the surface "Diagnostics" — a pane of that name is where a friend and Settings search look;
  R-13r-5's verbatim-evidence promise wants the JSON ALWAYS VISIBLE at a pane's height (B
  lands it at the bottom of the longest pane's scroll; C puts the evidence one click behind
  the promise that says it is shown); every existing pane keeps its shape and blurb (the
  row-52/59 fold lessons stay honored); one pane = one concern, and a later diagnostics thing
  joins it. The against (a mostly-empty pane) is answered by the calm one-line empty state.
  The blurb and captions are approved as FUNCTIONAL copy (13s re-voices); `stethoscope`
  stands. The not-proposed exclusions (Protection; a second Send Feedback door) are ratified
  as recorded. Piece 5 builds to this; the walk sheet's optional arm names the Diagnostics
  pane.
- **U3-B VERIFIED BY THE ORCHESTRATOR (2026-10-04, the seam spot-check by its own hands):** tree
  clean at `73ee3984` = origin, zero instances; the whole-range scope guard shows ZERO
  `Sources/`, `Server/`, `Shared/` and mobile lines; the five U3-B-adjacent suites RE-RUN —
  **62 tests in 5 suites GREEN, no skips** (CrashReporting · DiagnosticsPane · SupportDraft ·
  SyntheticCrashReport · the registry walk); the staged walk sheet READ IN FULL and matching
  R-13r-16 (the page-at-0.9.0-during-the-walk subtlety, the inline day-counter blocks, the
  re-arm road, the optional arm (g), the N-0 [O] staging with the hazard re-check); the
  mutation run's four-mutants-all-caught record read; QUESTIONS #181 (a)–(i) in place.
  **U3 IS BUILT COMPLETE (U3-A + U3-B); what remains of the phase: the N-0 staging (her two
  gates → the DMG dry run → the 0.9.0/0.9.1 releases + publishes) → HER WALK on the new
  computer → the ONE fable-reviewer ladder over U1–U3 (finals green modulo 19e's named red) →
  closeout.** The F-W5 no-Mail-account fact and the ladder flags ride the record as written.
- **THE DMG WINDOW, SEEN BY HER AND ADJUSTED (2026-10-04, pre-release):** the toggle flipped
  (the probe reads ALLOWED), the dry run PASSED 5/5 twice, and she judged the mounted window
  live. Her feedback, verbatim: *"the arrow looks a bit silly, can you fix the arrow being so
  long please? otherwise looks good"* — the orchestrator's own small fix at adjudication (the
  skill's allowance): the gap-spanning shaft becomes a SHORT 72-pt mark centred in the gap,
  and the caption drops 15 → 13 pt (its tail grazed the Applications icon in her capture).
  Re-run: PASS 5/5, remounted for her eyes. The ladder reviews the diff with U3-A's piece 5.
- **N-0 IN FLIGHT — 0.9.0 RELEASED AND PUBLISHED (2026-10-04, the orchestrator under
  R-13r-15/16; her two gates closed first: the toggle flipped and probe-verified ALLOWED, the
  DMG window dry-run PASS 5/5 twice and APPROVED at her eyes after her arrow fix, her release
  notes landed verbatim-faithful):** `release.sh --version 0.9.0` exit 0 — the export drill
  56/56, app and DMG notarizations both **Accepted** (0 issues), the window laid out and read
  back inside the shipped DMG, shipped bytes 21,202,362 · sha256 `db62b7fb…cb74e603`, build
  **4911**, her notes riding the appcast verbatim with the edSignature VERIFYING under the
  baked key; dSYMs filed at `~/Library/Developer/Variorum/Releases/0.9.0/`. **Published per
  the site runbook in the locked order:** the DMG to R2 (verify-published dmg PASS,
  byte-identical), then the appcast + `src/data/variorum.json` → 0.9.0, deployed
  (verify-published appcast PASS; **the no-cache header VERIFIED LIVE for the first time** —
  the runbook's own open item closed); the page renders "Variorum 0.9.0" with the Download
  button at the exact dl URL; the site repo committed and pushed (`e304b43`). **One lesson
  recorded:** a pre-upload preflight 404 can be NEGATIVELY CACHED at an edge node for a
  couple of minutes and a Workers deploy propagates per-POP — two transient 404s read
  seconds after byte-identical PASSes; the answer is wait-and-re-verify (both arms re-ran
  PASS), never a re-upload. **0.9.1 IN FLIGHT:** its functional notes + the version bump
  committed (`c4974c4a`); `release.sh --version 0.9.1` running; its publish follows the same
  order, the page's data file STAYING at 0.9.0 until after her walk (the sheet's shape).
- **0.9.1 BUILT (second run) — PUBLISH PAUSED AT A CACHED 404, HER PURGE ASKED (2026-10-04).**
  Run 1 FAILED SAFELY at the export drill: the stamp assertion caught `4913 ≠ expected 4912` —
  the orchestrator had committed the N-0 record MID-BUILD and the commit-count moved under the
  run. **LESSON (binding on this orchestrator): NO repo commits while a release run is in
  flight — the build number is the commit count.** Run 2 from the settled HEAD: exit 0, 57/57
  twice, both notarizations Accepted, `Variorum-0.9.1.dmg` 21,203,033 bytes · sha256
  `6fedd07e…9751579f`, the appcast carrying BOTH items, verify-appcast PASS. **The publish:**
  the DMG uploaded to R2 and confirmed IN THE BUCKET byte-perfect (a direct
  `wrangler r2 object get` sha256-matches), but the PUBLIC URL serves a CACHED 404
  (`cf-cache-status: HIT`, age 171, `max-age=14400`) — the runbook's own preflight HEAD, run
  seconds before the upload, seeded a 404 the edge cached for up to 4 h (0.9.0 met the same
  shape for ~2 minutes; the TTL is evidently POP-/response-dependent). **The DMG-FIRST order
  did its job: the live appcast still advertises ONLY 0.9.0, so no client can be offered the
  dead link.** The unblock is a one-URL dashboard purge (zone-level — outside wrangler's OAuth
  by the runbook's own access note): HER HANDS, asked. **LESSON TO PROPOSE for the site
  runbook (their file — proposed, not edited):** the never-overwrite preflight should check
  the BUCKET (`wrangler r2 object head`), never the public URL, which seeds exactly this
  cached 404. The appcast push, the page deploy and the N-0(e) public-state checks resume the
  moment the purged URL serves the DMG.
- **N-0 COMPLETE — THE WALK IS GREEN-LIT (2026-10-04 23:10:53Z, the N-0(f) START):** the cached
  404 cleared (her purge road; the watch saw the URL go live), the published 0.9.1 DMG verified
  BYTE-IDENTICAL from the public URL, the two-entry appcast deployed and verified (byte-identical;
  the newest enclosure live at its declared 21,203,033 bytes), and the N-0(e) public state reads
  exactly the sheet's expectation — the feed lists **0.9.0 AND 0.9.1**, the page still offers
  **Download Variorum 0.9.0** (it moves to 0.9.1 only after the walk), both site commits pushed
  (`e304b43`, `dbb12a3`). SHE IS WALKING LIVE on the new computer (steps 1–4 released early at
  her ask, mid-snag; step 5's update leg released at this green light). Her reports land here
  as findings.
- **THE U3 WALK VERDICT (2026-10-04, her report, verbatim: *"ok i've downloaded 0.9.0, it
  worked, downloaded the update, and it worked! I think that everything is set up and solid.
  I'm not running the commands to advance the day time for now - I tried this with my first
  beta on a friends computer so I don't feel like doing all that but I'm sure it works fine.
  YAY! first external user exists"*): PASS on the arms she ran, honestly scoped.** What
  PASSED at her hands on the REAL public road, on a computer that is not the M3: the page →
  the 0.9.0 download → the DMG → the install → the first open → **Check for Updates… finding
  0.9.1 on the public feed and installing it** — the phase's core promise, proven end to end
  by a genuinely external install. **THE FIRST EXTERNAL USER EXISTS** — the walk ran on a
  FRIEND'S computer, at her own hand; the friends beta has factually begun. **Arms DECLINED
  at her word:** the day-counter cadence arms (e) — her words above; their acceptance stands
  on the U3-A dev-store walk's captures (the backup offer fired on day 5, Set Up… opened the
  sheet; What's New show-once walked) + the 15 CalmAsks pins with the 30-day simulated run +
  the mutation runs. Arms (f)/(g) unreported — their standing evidence is U3-B's pins and
  captures; the first on-screen mail draft remains unobserved (F-W5's open question, #181
  (i)). No captures were filed (her report is the record). **Consequences recorded:** the
  pre-ladder fence ("no link to friends until the closeout") was overtaken by her own act —
  her prerogative, and the designed answer already stands: any ladder-driven fix ships as
  0.9.2 through the feed and the friend's install self-updates (the lockstep synergy, live).
  N-10(b): the page moves to 0.9.1 NOW. **U3 CLOSES ON THIS VERDICT; the ladder is next.**
- **U4 — DEFERRED post-launch (her word).**
- **LADDER ROUND 1 — DONE (2026-10-04, fable-reviewer, REVIEW_PROMPT verbatim, zero framing;
  diff a627434a..0a3df855 excluding the 19 ledger's own-reviewed entries): 0 BLOCKER · 0
  MAJOR · 3 MINOR · 2 NIT; nothing requiring an emergency 0.9.2.** Findings (recorded here
  BEFORE any fix session sees them; the cross-model exchange follows):
  - **F1 [MINOR] · Tools/Release/release.sh:119** — the release preflight HEADs the public
    DMG URL and seeds a negatively-cached 404 over the release's own canonical URL (the
    phase's live incident traced: `cf-cache-status: HIT`, age 171, max-age 14400 at 0.9.1's
    publish; the publish then pauses on a zone-level purge that is HER HANDS). Proposed fix:
    cache-bust the preflight request only (`?preflight=$(uuidgen)` — the cache key includes
    the query string, the canonical URL untouched); keep verify-published on the canonical
    URL post-upload. Ops-script class, no Swift pin — labelled honestly.
  - **F2 [MINOR] · Tools/Release/make-appcast.sh:50** — `ED_PUBLIC_KEY` is a THIRD duplicated
    key literal (plist · verify-export.sh · here); a future rotation updating this constant +
    verify-export's without the Keychain/plist staying twins yields a PASS over an appcast
    every shipped install refuses — an availability failure found only at users. Proposed
    fix: read it from the one baked source (`PlistBuddy Print :SUPublicEDKey` on
    VariorumInfo.plist), so the verification key is BY CONSTRUCTION the shipped key
    (verify-export's copy is the opposite-direction tripwire and may stay). Script class.
  - **F3 [MINOR] · Features/CalmAsks/CalmAsks.swift:222–232 + RootView's backup-ask
    registration** — `register` replaces by id and discards the prior host's registration:
    window A registers, window B's register drops A's, B closes and unregisters → ZERO
    registrations for `backupFolder` while A stays open; A's `.task` never re-fires, so the
    ask is dormant until a new window or the next launch. Self-healing and data-free
    (MINOR). Red-on-old pin named: register A, register B, unregister(B) → `registeredIDs`
    still contains `backupFolder` (fails today). Fix: per-(id, host) registrations with
    rank-order dedupe at evaluate, or unregister falls back to the surviving same-id
    registration.
  - **F4 [NIT] · SyncStatusViews' `.checkForUpdates` act / UpdateChannel.syncRowDoor** — the
    sync row's door doesn't consult `canCheckNow`, so pressed while the deferred permission
    window is up it starts a user-initiated check beside it (both resolve gracefully;
    two-window cosmetic corner; unpinnable without a live Sparkle controller). Fix if
    wanted: guard the closure on `canCheckNow`.
  - **F5 [NIT] · Features/Diagnostics/SupportMail.swift:102** — `pendingFailure` is a single
    slot; two Send Report… composes in flight and the first's late-failure fallback is
    silently dropped (nothing ever sent; graceful; the U3-B record flags the shape). Fix if
    wanted: key the pending road per NSSharingService instance.
  - **Every recorded ladder flag ADJUDICATED by the reviewer** (the editor-seam line ACCEPTED
    with TEXTKIT2 re-read + the 19a absolute pin; the three undeclared menu doors as P-1
    readings on their precedents; the `secondary` door; the deferral selector and
    `askPermission()` both VERIFIED against Sparkle 2.10.0 source incl. the re-arm
    notification road; script sandboxing; hdiutil; the Finder gate; `@unchecked Sendable`;
    the MX* deprecation posture; the two `.surface` acts). **CLEAN BILL** on custody, the
    Debug fence, consent/calm, R-13r-13's exact classifier (zero `Sync/` verified), crash
    reporting's OFF proof and no-send-road, What's New's one source, the pipeline's
    immutability/hygiene, the suites' one named pre-existing red (19e), and commit hygiene.
    The reviewer ran no Mac suites itself (her real-store app was LIVE — the zero-instance
    discipline held); the fix pass owes the suite run at a quiet window.
  - **The exchange:** F1–F4 to the U3-A implementer and F5 to the U3-B implementer VERBATIM
    for agree/dispute; the reviewer makes the final call and implements its confirmed fixes
    itself (F3 pin-first; F1/F2 as script changes labelled no-pin); then suite green and one
    implementer sanity pass; round 2 re-reviews the fixes under a FRESH reviewer.
  - **F5 — the U3-B implementer AGREES (NIT), with the mechanism SHARPENED on its own
    re-read** (lines 102/121/136/142–143): the single slot is not only a drop — with drafts
    A then B in flight, A's late failure runs B's fallback (the WRONG draft's file shown and
    named), and A's SUCCESS nils the slot so B's later failure has no road at all. Nothing
    is ever sent in any case; the measured callback window is ~1.5 s. It endorses the
    reviewer's per-service-instance keying (`[ObjectIdentifier(sharingService): road]`).
  - **F1–F4 — the U3-A implementer AGREES ON ALL FOUR, disputes none** (each cited line
    re-read at `87ccf7ad`; nothing fixed, per the exchange). Riders recorded: **F1** — when
    the cache-busted preflight lands, MEASURE ONCE that a busted HEAD on an
    already-published name (e.g. `Variorum-0.9.0.dmg?preflight=<uuid>`) still answers 200,
    or the immutability refusal loses its force; **F3** — its own prior pin missed exactly
    this (it unregistered a never-registered host), and it prefers the per-(id, host) fix
    with `evaluate` picking the most recent surviving entry per id in rank order (the
    `present` lookup following the same choice); **F4** — guarding inside
    `UpdateChannel.checkForUpdates()` itself would cover any future door (either shape fine).
  - **HER WINDOW OPENED MID-PASS (2026-10-04, verbatim: *"my app is quit and ready for
    refresh, i'm away from the computer, run tests at your leisure"*):** zero instances
    confirmed by the orchestrator; the reviewer told to run the FULL fix-pass suites; the
    away posture is PROVISIONAL-and-continue (nothing author-gated remains before round 2);
    the `/Applications` refresh stays the CLOSEOUT'S act behind the A1 rail — her "ready
    for refresh" is its pre-authorization, not a reordering.
  - **ZERO DISPUTES. The fix pass is the REVIEWER'S** (authorized by follow-up message):
    final calls on all five, F3 pin-first red-on-old, F1/F2 as script changes labelled
    no-pin (F1's 200-on-published-name measurement included), F4/F5 at its call; the fix
    suites at a ZERO-INSTANCE window only (her real-store app may be live — pause and
    report rather than run beside it or touch it); then the implementer sanity pass and
    round 2 under a FRESH reviewer.
  - **THE SANITY PASS (the U3-A implementer over fc5ce29a..b18b70d4; F5 outside its range,
    not judged): AGREE-CLEAN on F3 (the new pin confirmed red-on-old by its own trace; the
    lock/unlock road intact), F1 (the rider's measurement honoured), F2 (the `|| true`
    set-e safety and the shape check read), and the VersionSchemeTests repair (the mobile
    1.0 outside the filter; the 0.9.1 notes keep WhatsNewTests green) — with ONE NIT ON
    F4:** the channel guard's bare `return` makes the sync row's door a
    door-that-does-nothing when the deferred permission window sits BEHIND the main window
    (P-2's class, in the narrow out-of-date-sync × ask-on-screen corner) — Sparkle's own
    branch calls `showUpdateInFocus` there (SPUUpdater.m ~697–700 → SPUStandardUserDriver
    .m:466–488, raising the prompt and activating the app); the suggested mirror is the
    driver's `showUpdateInFocus?()` in place of the bare return. Unpinnable without a live
    controller, like F4 itself. ROUTED to the reviewer for the final call (fix or
    record-only) before round 2 spawns.
- **THE ROUND-1 FIX PASS (the SAME reviewer session, authorized 2026-10-04; LIVE STATUS from
  the first commit — DONE(hash) / IN-PROGRESS / PENDING):** final calls on all five findings
  are CONFIRMED AS FOUND (zero disputes; the exchange's sharpenings adopted — F5's
  per-service keying, F3's per-(id, host) shape with the most-recent-surviving-per-id
  evaluate AND present lookup, F4 as the channel-level guard covering future doors, F1's
  busted-HEAD-on-published-name measurement). Per-piece states:
  - **F3 (the one pinned bug-class fix) — DONE (`7f792dc3`).** Pin FIRST:
    `CalmAsksTests.aClosingWindowLeavesTheOtherWindowsRegistrationStanding` ran RED on the
    old code (3 issues: the registration dropped; the ask never presented) BEFORE the fix,
    and RED AGAIN by stash-revert after it (the whole suite: exactly the one pin red, 15
    green) — the first revert attempt's per-test `-only-testing` id matched 0 tests
    (vacuous, discarded; the settling-probe lesson held) and was re-run as the full suite.
    The fix: `register` keeps one registration per (id, host); `effective` (the newest
    surviving registration per id, rank order) is the ONE list `evaluate`'s snapshot AND
    its `present` lookup read — the exchange's preferred shape. Suite 16/16 green.
  - **F4 — DONE (`dd44aff3`).** The guard inside `UpdateChannel.checkForUpdates()` on
    `!isAskingPermission` ONLY (deliberately NOT on `canCheckForUpdates`: Sparkle's own
    mid-session `checkForUpdates` shows the running session in focus — behaviour worth
    keeping; the double-window corner is exactly the deferred ask's window, which Sparkle
    cannot see). NIT hardening, NO PIN — the state is unreachable without a live Sparkle
    controller (labelled honestly, in the commit too).
  - **F5 — DONE (`15ce51b5`).** The pending failure road keyed per service instance
    (`[ObjectIdentifier: (service, road)]`, the service retained for the key's life, the
    entry leaving in either callback); `compose`'s bookkeeping half separable
    (`expectFailureRoad`) so the delegate contract is pinnable without `perform`. Pin:
    `SupportDraftTests.aLateFailureRunsOnlyItsOwnDraftsRoadAndASuccessClearsOnlyItsOwn`
    (two never-performed services: A's late failure runs A's road never B's; B's success
    clears only B's; a cancel spends the road). Red-on-old NOT demonstrable (the old
    single-slot shape is reachable only through `perform`, which opens Mail) — **the
    MUTANT check stood in: single-slot semantics restored under the new API → the pin RED
    with 3 issues, exactly it; restored by `git checkout --`, tree clean.** Suite 13/13.
  - **F1 — DONE (`d3cd0079`).** `release.sh`'s preflight HEAD cache-busted
    (`?preflight=$(uuidgen)` — the edge cache keys on the full URL, so the 404 an
    unpublished name earns caches under a throwaway URL, never the canonical one).
    **THE RIDER'S MEASUREMENT (2026-10-04, both arms):** a busted HEAD on the PUBLISHED
    `Variorum-0.9.0.dmg` answered **HTTP 200 · cf-cache-status: MISS · content-length
    21,202,362** (the recorded byte size) — the immutability refusal keeps its force; a
    busted HEAD on an unpublished name (`Variorum-0.9.9.dmg`) answered **404**. `bash -n`
    clean. Script change, NO PIN (ops class); its next real run is the next release's.
  - **F2 — DONE (`0d2f3f05`).** `make-appcast.sh` reads `ED_PUBLIC_KEY` out of
    `App/Variorum/VariorumInfo.plist` (`PlistBuddy Print :SUPublicEDKey`, with a
    44-char-base64 shape refusal naming the real cause) — the appcast verified BY
    CONSTRUCTION under the shipped key; `verify-export.sh`'s literal STAYS as the
    opposite-direction tripwire. Verified: the plist read returns byte-identically the
    retired literal. `bash -n` clean. Script change, NO PIN.
  - **A PRE-EXISTING RED SURFACED BY THIS PASS'S OWN SUITE RUN, repaired (`7579b4fd`) —
    flagged for round 2:** `VersionSchemeTests.theStampPhaseIsTheMacTargetsLastPhase…`
    pinned the literal `MARKETING_VERSION = 0.9.0;` and went red at `c4974c4a`'s ruled
    0.9.1 bump (R-13r-6's ADJUDICATED reading: the repo version increments with each beta
    release; the finals had last run at `73ee3984`, BEFORE the bump, so nobody had seen
    it). The pin now holds the ruling's SHAPE — exactly two 0.9.x lines (the Mac target's
    two configurations), both carrying the version the running test host was built as —
    so every future release bump stays green while the letter (two configs, same value,
    no other target) still binds. Test-side repair of a stale literal, NOT a production
    fix; 3/3 green.
  - **THE SUITE RUN — DONE at a REAL zero-instance window** (her word relayed by the
    orchestrator mid-pass — "my app is quit and ready for refresh… run tests at your
    leisure" — and verified by this session's own `pgrep -fl 'Variorum.app/Contents/MacOS'`
    → no match; earlier in the pass her app WAS live, PID 52395, and only the touched pin
    suites ran then, per the fallback authorization):
    - the 31-suite finals family (U3-B's close set): **`Test run with 274 tests in 31
      suites` — 1 issue, EXACTLY the named pre-existing 19e runbook red**, the 7
      `DebugOracleSingletonWindowTests` opt-in skips as always (+2 tests over the 272
      baseline = this pass's two new pins);
    - the 34-suite tutorial/command-routing/shell-landing/windows/note-box family:
      **166/34 PASSED** (the U3-A baseline exact; a first attempt whose extracted suite
      list matched 0 tests was DISCARDED as vacuous and re-run for real);
    - `OneTimeCodeAutoFillTests` (the one U2-close suite in neither family): 2/2;
    - the CORE package: **`swift test` → 2174 tests in 244 suites PASSED** (the 19a
      baseline exact).
    Zero `Sync/`, zero schema, zero `Shared/`, zero mobile-target lines in this pass
    (CalmAsks/UpdateChannel/SupportMail are Mac-only; scripts + tests otherwise), so no
    mobile rebuild is owed. Nothing published; the touched pipeline scripts' next real run
    is the next release's. **The fix pass is COMPLETE; the implementer sanity pass and
    round 2 (a FRESH reviewer) are next.**
  - **THE SANITY PASS'S ONE NIT ON F4 — THE FINAL CALL: ACCEPTED AND LANDED
    (`a53aa77e`).** The cited mechanism was VERIFIED in the 2.10.0 source first (the
    standing practice): `SPUUpdater checkForUpdates` under `_showingPermissionRequest`
    calls `showUpdateInFocus` (when the driver responds) and returns;
    `SPUStandardUserDriver showUpdateInFocus` raises `_permissionPrompt` via `showWindow:`
    and activates the app; and `showUpdateInFocus` sits in the protocol's `@optional`
    section with NO declaration in the standard driver's public header — so the Swift call
    is the optional-protocol form on the driver cast `as any SPUUserDriver`. The guard now
    MIRRORS Sparkle's own move: a check pressed while the deferred ask is up brings the
    permission window FORWARD instead of doing nothing silently (P-2 whole again in the
    out-of-date-sync × ask-on-screen corner). Like F4 itself: NO PIN, labelled honestly
    (unreachable without a live controller). Channel-adjacent suites re-run at a verified
    zero-instance window: **29/3 green** (UpdateChannel · CalmAsks · SyncOutOfDateFace).
    **THE FIX SET IS FINAL at `a53aa77e`: six production/test commits (7f792dc3 ·
    dd44aff3 · 15ce51b5 · d3cd0079 · 0d2f3f05 · 7579b4fd) + this refinement; round 2
    spawns under a FRESH reviewer, with the 7579b4fd pin repair and this F4 refinement
    explicitly in its view.**
  - **LADDER ROUND 2 — CLOSED CLEAN (2026-10-04, the FRESH reviewer over the final fix set
    at `da325b3d`): 0 BLOCKER · 0 MAJOR · 0 MINOR · 3 NIT, every fix judged SOUND with its
    mechanism re-verified cold** (F3's red-on-old traced by the reviewer's own hands; F4's
    Sparkle claims re-verified at the cited 2.10.0 lines including the @optional header
    fact; F5's single-slot mutant trace reproduced at exactly 3 issues; F2's plist read
    byte-identical to the retired literal; the pin repair probed on every hollowness road —
    diverged configs, a third 0.9.x line, host/pbxproj skew — and judged unable to go
    hollow); the five touched suites re-run BY THE REVIEWER at a verified zero-instance
    window: **45 tests / 5 suites PASSED**. NO round 3 earned. **THE LADDER IS CLOSED:
    round 1 (0/0/3/2, zero disputes, all five fixed + the F4 refinement) · round 2
    (0/0/0/3).**
  - **The three round-2 NITs, DISPOSITIONED RECORD-ONLY by the orchestrator (the reviewer's
    own eligibility reading, accepted):** (N1) the ~millisecond post-answer gap in the F4
    guard (`isAskingPermission` clears one main-drain after Sparkle nils its prompt) —
    unpinnable, not a regression, the pre-refinement silence confined to a window no hand
    can hit deliberately; the synchronous-clear shape is on record if it ever earns
    building. (N2) the F1 rider's 200/MISS arm doesn't alone discriminate
    query-in-cache-key from plain expiry — the mechanism rests on Cloudflare's documented
    default and the fix is strictly no worse either way; the discriminating back-to-back
    HEAD comparison is ONE line at the NEXT release (carried in the handoff). (N3) the
    reshaped version pin reds at 1.0.0 with a message that won't name R-13r-6's scheme
    event — the red is the pin DOING ITS JOB at a deliberate scheme event; the message fold
    is noted for whoever runs 1.0.0.

---

## U1 RECORD (the implementer's LIVE STATUS — Opus, 2026-10-04; DONE(hash) / IN-PROGRESS / PENDING)

**NOT DONE BY THIS UNIT (stated first, per the contract):**
- The LIVE drill leg (b) is AUTHOR-GATED. It is STAGED here (piece 4), never run: this session
  never launched the export, never touched the real store, never refreshed `/Applications`.
- No Mac or core suite was run: none compiles under Xcode 27 until 19a.
- No notarization submit (U2's). No entitlements edit, no Info.plist keys, no version stamping, no
  Sparkle, zero `Sync/`, zero schema. The test targets and `MobileChipFlow.swift` are untouched
  (19a's).
- Run 1's leftover real-store bundles were NOT removed: the harness safety check stopped the
  `rm -rf`, and the removal is left to the orchestrator or her.

**U1 STATE (2026-10-04, the implementer's stop): the fix, the road, the static drill DONE (35/35);
the LIVE drill STAGED (piece 4's checklist), waiting on HER launch, which the orchestrator
coordinates.** **SUPERSEDED THE SAME SITTING — U1 IS CLOSED: the LIVE drill RAN at her hands
and PASSED all five arms (the VERDICT at this record's tail, step 8); the forward notes below
were each dispositioned at her word (the LIVE STATUS's drill-sitting bullet).** Pieces below.
Forward notes for the orchestrator, none of them this unit's:
- A pre-existing indexed real-store-id Release build sits in Xcode's default DerivedData (piece 3).
- Run 1's leftover real-store bundles await removal (piece 4).
- Her OWN eventual move to a Developer ID build would meet the bookmark question (piece 4's
  predictions), if the community report holds. Friends start fresh, so it cannot touch them.
  R-13r-7 keeps her on hand-copies.

**U1 RESUMED (2026-10-04) after the toolchain gate. The orchestrator's adjudication (`4d1afcd8`, the
LIVE STATUS bullet above) took OPTION (a), REFINED.** The history: the Xcode-27 probe found that the
Mac APP did not compile (ONE error, in the editor seam). U1 stopped and reported, nothing landed. The
orchestrator then ruled that U1 lands the use-site line and proceeds; the 28 test/mobile errors are
**19a's** (not this unit's; the test targets and `MobileChipFlow.swift` stay untouched here).
- **THE FIX — DONE (`a8691989`), its own commit, EDITOR-SEAM-flagged for 13r's Fable ladder.**
  `PaneSurface.swift:1076` now reads `tokens.map { _ in Color.clear } ?? Color.gray.opacity(0.25)`
  (the probe's shape, the same value on both arms), plus a two-line comment naming why it is not
  `== nil`. `TEXTKIT2_NOTES.md` was re-read first (the editor-seam rule); no TK2 API, storage or
  layout is touched (a SwiftUI `Color` choice in a pure function). **Verified: the Mac app builds
  GREEN CLEAN after it** (`** BUILD SUCCEEDED **`, fresh `-derivedDataPath
  App/Variorum/DerivedData/13r-u1/fix-debug`, log `fix-xcodebuild-debug.log`). **Pin story:**
  `PaneSurfaceTests`' five `PaneDecoration.resolve` pins prove the line behavior-preserving once
  19a restores the Xcode-27 suite base. No Mac suite can compile before then, so none was run (the
  orchestrator's order).

**Toolchain at session start (re-read, matches the pinned pair):** macOS 27.0 (26A428) · Xcode 27.0
(27A266a) · `xcode-select -p` = `/Applications/Xcode.app/Contents/Developer`. Zero-instance check
(`pgrep -fl 'Variorum.app/Contents/MacOS'`) at session start: no match.

**Pieces:**
1. **The Xcode-27 clean-build probe** — DONE (census complete; the result is RED, see the gate above).
   - `swift package clean && swift build` (repo root, Swift 6.4 / swiftlang-6.4.0.34.1): **GREEN**
     — `Build complete!`, exit 0, 6 benign warnings (Swift 6.4's new "`nonisolated(unsafe)` is
     unnecessary for a constant with Sendable type DateFormatter" ×4; a dependency's `v4`
     deprecation ×2). Log: `App/Variorum/DerivedData/13r-u1/probe-swift-build.log`.
   - `xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath
     App/Variorum/DerivedData/13r-u1/probe-debug build` (FRESH path = clean): **RED — exit 65,
     ONE error** — `Variorum/Surface/PaneSurface.swift:1076:28: error: main actor-isolated
     conformance of 'VoiceTokens' to 'Equatable' cannot be used in nonisolated context
     [#IsolatedConformances]`. Mechanism: `PaneDecoration` is a `nonisolated struct`; its static
     `resolve(isLive:indicator:tokens:)` compares `tokens == nil` on a `VoiceTokens?`; Swift 6.4
     resolves that through `Optional<Wrapped: Equatable>.==`, and `VoiceTokens: Equatable`
     (`Shared/Theme/VoiceTokens.swift:32`) is INFERRED main-actor-isolated under the target's
     `-default-isolation=MainActor` + `InferIsolatedConformances`. The EDITOR SEAM (CLAUDE.md
     names `PaneSurface`) — per the brief, REPORTED, not landed. Log:
     `App/Variorum/DerivedData/13r-u1/probe-xcodebuild-debug.log`.
   - **The census probe — RESTORED, nothing in flight.** A temporary one-line edit at
     `PaneSurface.swift:1076` (`tokens == nil ? Color.gray.opacity(0.25) : .clear` →
     `tokens.map { _ in Color.clear } ?? Color.gray.opacity(0.25)`, same value on both arms) was
     applied ONLY to learn what else breaks; it was restored with `git checkout --` (the diff
     verified to be that one line first). sha256 re-read = `26525f05…500264e8`, the pre-probe value;
     `git status` clean.
   - **WITH the probe line, the Mac APP builds** — `** BUILD SUCCEEDED **`, exit 0, 27 warnings
     (log `probe-xcodebuild-debug2.log`). So the APP's whole Xcode-27 census is that ONE line.
   - **The Mac TEST target `VariorumTests`** (`build-for-testing`, with the probe line): **RED, 20
     unique errors in 8 files** — `PaletteDerivationTests` ×10 (main-actor-isolated statics
     `all` / `resolved(_:tint:)` used from nonisolated test contexts) · `PlainPasteTests` ×2
     (`MemberImportVisibility`: missing `import VariorumCore`) · `TagAndFolderTests` ×2,
     `TutorialWalkTests` ×2, `LifecycleFacesTests` ×1, `PoolDragTests` ×1,
     `StructuralGestureTests` ×1 (GRDB `Row`'s Sendable conformance is unavailable, now enforced)
     · `EditorSeamCostTests` ×1 (a main-actor static called from a nonisolated context). Log
     `probe-xcodebuild-bft.log`. **No Mac suite can run under Xcode 27 until these are migrated**
     (that includes `PaneSurfaceTests`, the five pins on `PaneDecoration.resolve`).
   - **The CORE package's tests** (`swift build --build-tests`): **RED, 7 unique errors, ALL in
     `Tests/VariorumCoreTests/FurnitureConvergenceRepairTests.swift`** (lines 433/727/803: an
     `async` expression missing `await` + `Row`'s unavailable Sendable; line 864: `Row` Sendable).
     A test file under `Tests/`, not `Sources/VariorumCore/Sync/`. Log
     `probe-swift-build-tests.log`. **`swift test` cannot run under Xcode 27 until it is migrated.**
   - **The MOBILE target** (`-scheme VariorumMobile -destination 'generic/platform=iOS Simulator'`,
     build only; iOS 27.0 SDK + simulator runtime are installed): **RED, ONE error** —
     `VariorumMobile/Features/Write/MobileChipFlow.swift:81:28: the compiler is unable to type-check
     this expression in reasonable time` (the `height` reduce in the chip-flow layout's
     `sizeThatFits`), once per simulator architecture. Log `probe-mobile-build.log`.
   - All logs are under `App/Variorum/DerivedData/13r-u1/` (gitignored, local).

**THE ROUTING QUESTION FOR THE ORCHESTRATOR (U1 cannot proceed past it):**
- **Only the APP line gates U1.** The archive needs the app to compile; the static drill needs the
  archive. The test-target, core-test and mobile breakages do NOT gate U1's acceptance (it is
  signing evidence, not a suite), but they DO gate every later suite run: the phase ladder's "suite
  green", U2/U3's pins, and every other phase.
- **Options, proposed (not taken):** (a) authorize U1 to land the app's one line as its OWN commit
  ahead of the export road, flagged for the Fable ladder (editor-seam file; the change is the probe
  line above: a pure function, the same value on both arms, no TK2 API touched), and route the 28
  test/mobile errors to a standing-fixes entry (an Xcode-27 migration entry in the 19 ledger) that
  runs before the ladder; (b) run that migration entry FIRST, app line included, under its own cast
  (it touches the editor seam and a sync-convergence test file, so the cast is for the orchestrator to
  set), then resume U1 from this record; (c) another fix for the app line (for example, declare
  `VoiceTokens`'s `Equatable` conformance `nonisolated` in `Shared/Theme/VoiceTokens.swift`). That is
  wider (a cross-platform Theme type) and the implementer does not recommend it.
- **What resumes on either road:** pieces 2–4 as designed below. Pieces 2 and 4 (the scripts, the
  plist, the profile copy, the staged checklist) do NOT need the app to compile and could be built
  first. Piece 3 (the archive and the static drill) needs the app line fixed.
2. **The archive/export road** — BUILT (this commit); its first real run is piece 3 (PENDING).
   `Tools/Release/`:
   - `archive-and-export.sh [--out DIR]`. DIR (default `App/Variorum/DerivedData/release/<UTC>`)
     must be empty, so every run is clean by construction (a fresh `-derivedDataPath` inside it).
     It then:
     - writes `BUILD-INFO.txt` (the commit, a dirty-tree flag, the toolchain);
     - REFUSES (exit 3) if any Variorum process runs: `pgrep -fl 'Variorum.app/Contents/MacOS'`,
       re-checked before the archive, before the export and at the end; it never quits or kills one;
     - REFUSES (exit 4) unless the signing inputs agree: the method is `developer-id`; the profile
       UUID ExportOptions names is the versioned file's UUID; ExportOptions' certificate SHA-1 is a
       DeveloperCertificate of that profile AND a valid Keychain identity; the profile's app-id is
       `io.lduarte.Variorum`; the profile is unexpired;
     - INSTALLS the profile into `~/Library/Developer/Xcode/UserData/Provisioning
       Profiles/<UUID>.provisionprofile` when it is absent (a copy; it refuses if a different file
       sits there).
     - archives (`-configuration Release`, `generic/platform=macOS`), then exports with
       `ExportOptions.plist`;
     - unregisters every `Variorum.app` it made from LaunchServices (`lsregister -u`), so no
       Spotlight / `open -b` / Dock road resolves her app to them;
     - runs `verify-export.sh` (with `--compare-with /Applications/Variorum.app` when present) into
       `verify.txt`.
   - `ExportOptions.plist`: `method developer-id`, `signingStyle manual`, `signingCertificate`
     *[removed for publication]*
     *[removed for publication]*
   - `Variorum_Developer_ID.provisionprofile`: her profile, versioned (`cmp`-identical to
     `~/Downloads`; sha256 `f661fdea…eec5c97`). It is not a secret: it ships in every bundle as
     `embedded.provisionprofile`.
   - `verify-export.sh <app> [--compare-with <app>]`: the static drill as PASS/FAIL lines plus a
     VERDICT. It reads signatures only. It checks:
     - the seal: `codesign --verify --deep --strict`;
     - the identity: leaf = Developer ID Application, chain → Developer ID CA → Apple Root CA,
       hardened runtime flag, secure timestamp;
     - the entitlements: sandbox, BOTH keychain groups IN ORDER (the default group first) and
       exactly two, app-id, team-id, get-task-allow absent, the carried keys;
     - the embedded profile: byte-identical to the versioned copy; it authorizes each signed group
       through its pattern and matches app-id/team-id; the leaf SHA-1 is among its certificates;
       the UUID and certificate match ExportOptions;
     - nested Mach-O: Developer ID + runtime + timestamp each;
     - `spctl`: "rejected" + `source=Unnotarized Developer ID` counts as PASS before U2's notarize,
       "accepted" after it;
     - with `--compare-with`: the keychain groups are byte-identical to the other build's.
   - **Smoke-tested read-only against `/Applications/Variorum.app`** (Apple Development): exactly
     the Developer-ID-specific checks FAIL (11 of 33: leaf, chain, timestamp, get-task-allow, the
     profile's identity and UUID, the nested framework's signer, Gatekeeper); the shared ones pass.
     That proves the checks discriminate. **Found by it:** the bundle carries NESTED code,
     `Contents/Frameworks/SQLCipher.framework` (a dynamic framework), so the export must re-sign it
     under Developer ID (the nested check covers it). The Release binary is universal
     (x86_64 + arm64).
   - The scheme's Run config stays Debug and no build configuration was added (the scheme and
     project are untouched by this unit).
3. **The static drill leg (a)** — **DONE: PASSED 35/35 on both runs.** Run 2 is the drill build.
   - **RUN 2 (the FINAL script `5ba04cc1`, tree clean, 2026-10-04T10:11:16Z):** `--out
     App/Variorum/DerivedData/13r-u1/drill`, so the `.noindex` append was exercised, landing in
     `drill.noindex/`.
     - Every zero-instance check found no process. The signing inputs agreed. The profile was
       "already installed" (run 1's install, `cmp`-identical).
     - `** ARCHIVE SUCCEEDED **` → `** EXPORT SUCCEEDED **` → both copies unregistered →
       `LaunchServices: 0 registrations under …/drill.noindex` → **`VERDICT: PASS — 35 of 35
       checks`** (`drill.noindex/verify.txt`). Every line matches run 1's evidence below (secure
       timestamp `Oct 4, 2026 at 4:15:07 AM`).
     - Re-checked ~4 minutes later: 0 registrations for the drill build (the only `13r-u1`
       registrations are the Debug probe builds `.debug` and the mobile simulator build, as in
       every phase's build folders), and 0 Spotlight hits under `drill.noindex`.
   - **RUN 1 (script `c51b18d9`, tree clean):** `Tools/Release/archive-and-export.sh --out
     App/Variorum/DerivedData/13r-u1/release`, 2026-10-04T10:02:57Z.
     - Every zero-instance check found no process.
     - The signing inputs agreed. The profile was INSTALLED to Xcode's directory: it was absent,
       because her double-click had put it only in the Device Management store, which xcodebuild
       never reads.
     - `** ARCHIVE SUCCEEDED **` → `** EXPORT SUCCEEDED **` → **`VERDICT: PASS — 35 of 35 checks`**.
   - **The brief's literal commands, on that export (outputs abridged to the load-bearing lines):**
     - `codesign -d --entitlements - export/Variorum.app` →
       *[removed for publication]*
       *[removed for publication]*
       - `com.apple.security.app-sandbox` = **true**
       - `files.bookmarks.app-scope` = true, `files.user-selected.read-write` = true,
         `network.client` = true
       *[removed for publication]*
         *[removed for publication]*
       - NO `get-task-allow`.
     - `codesign -dv` → `CodeDirectory v=20500 … flags=0x10000(runtime)` (**HARDENED RUNTIME**);
       *[removed for publication]*
       Certification Authority` → `Apple Root CA`, `Timestamp=Oct 4, 2026 at 4:07:36 AM` (secure
       *[removed for publication]*
     - `security cms -D -i export/Variorum.app/Contents/embedded.provisionprofile` → `Name = Variorum
       *[removed for publication]*
       *[removed for publication]*
       *[removed for publication]*
       *[removed for publication]*
       *[removed for publication]*
     - `codesign --verify --deep --strict --verbose=2` → `valid on disk` + `satisfies its Designated
       Requirement`, exit 0. The nested `SQLCipher.framework` was re-signed under Developer ID with
       runtime and a timestamp.
     - `spctl --assess --type execute -vv` → `rejected` / **`source=Unnotarized Developer ID`** /
       *[removed for publication]*
       notarization-ready state, confirmed by the external-facts lookup (Apple DTS threads 124614,
       822378). U2's notarize + staple turns it to `accepted`.
     - `--compare-with /Applications/Variorum.app` (her daily drive, signed Apple Development
       *[removed for publication]*
       order; the app-id matches**. The ONLY entitlement difference is `get-task-allow => true` on
       hers (development signing injects it), absent on the export. That is exactly what
       notarization requires.
   - **A finding of run 1, FIXED in the road:** Spotlight indexed the export, and LaunchServices
     RE-REGISTERED it after the script's `lsregister -u`. That left a real-store-id bundle that
     Spotlight or `open -b io.lduarte.Variorum` could resolve her app to before the A1 rail. The run
     folder was moved to `release.noindex/` and both copies unregistered: **0 registrations after
     90 s**, and `mdfind` no longer lists it. The script now ALWAYS appends `.noindex` to its output
     folder and counts leftover registrations after the unregister. `verify-export.sh` re-run at
     the moved path: 35/35 (`release.noindex/verify-after-move.txt`).
   - **A pre-existing hazard, NOT this unit's, REPORTED:** Spotlight indexes a SECOND real-store-id
     Release build at
     `~/Library/Developer/Xcode/DerivedData/Variorum-dnpxwqhpxdqrdjbunktnzoahckpd/Build/Products/Release/Variorum.app`
     (an earlier refresh's build folder that was not removed). Left untouched for the orchestrator.
4. **The live drill leg (b), STAGED as a ready checklist** — DONE (this commit). NEVER RUN BY THIS
   SESSION: no launch, no store touch, no `/Applications` refresh. The orchestrator coordinates her
   launch.

   **THE BUILD UNDER TEST (exactly one):**
   `<home>/dev/variorum/App/Variorum/DerivedData/13r-u1/drill.noindex/export/Variorum.app`
   — run 2, script commit `5ba04cc1`, Developer ID, `CDHash=efdee49f8e803ef10fed1866833e77cf0ab43d6c`,
   executable sha256 `c14b5d8b…af80e66`, static drill 35/35 (`drill.noindex/verify.txt`).
   - It is NOT run 1's `release.noindex/export/Variorum.app`. That copy and the two `.xcarchive`
     app copies are also real-store-id bundles. This session's `rm -rf` of run 1's copies was
     STOPPED by the harness safety check, so their removal is left to the orchestrator or her. All
     four sit under `.noindex` with 0 LaunchServices registrations.

   **WHAT THE DRILL PREDICTS (measured at staging; the drill confirms or falsifies):**
   - **Keychain:** every custody family (store-key, store-key-escrow, e2ee-keys, apple-key, auth)
     lives in the DATA-PROTECTION keychain (`KeychainPartition`, `StoreKey`'s DP flag). Access there
     is governed by the access groups, and the export's groups are byte-identical to her build's.
     So: NO prompt beyond her posture's normal Touch ID (Apple TN3137).
   - **Legacy keychain:** the file-based keychain holds NO Variorum item. An attributes-only
     `security find-generic-password -s <service>` found "none" for all five services, and
     `security dump-keychain` lists no Variorum service. So the old-signature access-list password
     prompt CANNOT occur.
   - **Container:** the ownership metadata reads `Owners =
     *[removed for publication]*
     The export carries the same team and identifier. Predicted SILENT: WWDC23 10053 says "All apps
     signed with your Team ID can access data in your other app's containers by default, without a
     permission prompt"; DTS thread 741479 says Team ID, not the designated requirement. This exact
     Development → Developer ID switch is UNCONFIRMED by any source; the drill confirms it.
   - **App-scope bookmarks** (her backup folder; the reference panel's files): community-reported,
     unconfirmed, to fail to resolve under a changed signing identity. TRACED: no code path writes a
     bookmark back on resolve (`BackupDestination.resolve` returns `wasStale` and no caller
     re-mints; `ReferencesViewModel` only resolves). So the worst case is an honest "can't be
     found", and NOTHING is rewritten. Observation only; NOT a drill failure.
   - **Gatekeeper:** a locally built bundle carries no quarantine flag, so no Gatekeeper dialog
     gates this launch (the quarantined-DMG road is U2's walk).

   **THE CHECKLIST.** `[O]` = the orchestrator (shell, read-only unless stated); `[HER]` = her
   hands. `APP` = the drill build above. `C=$HOME/Library/Containers/io.lduarte.Variorum`.
   `S="$C/Data/Library/Application Support/Variorum"`. `LSR=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister`.
   - **0. Preconditions [O].**
     - (a) `pgrep -fl 'Variorum.app/Contents/MacOS'` → NO output. Discriminate by PATH: a Debug
       build or a test host also counts. She quits it; it is never quit or killed by a session.
     - (b) `codesign -dvvv "$APP" 2>&1 | grep CDHash` → `efdee49f…ab43d6c`, then
       `Tools/Release/verify-export.sh "$APP" --compare-with /Applications/Variorum.app` →
       `VERDICT: PASS — 35 of 35`.
     - (c) `$LSR -dump | grep -c 'drill.noindex'` → `0` (else `$LSR -u "$APP"`).
     - (d) For each of `store-key store-key-escrow e2ee-keys apple-key auth`:
       `security find-generic-password -s io.lduarte.Variorum.<name> >/dev/null 2>&1 && echo FOUND
       || echo none` → all `none`. Attributes only; NEVER `-g`. Any FOUND: STOP, report, do not
       launch.
   - **1. The A1 rail [O]** (the app CLOSED; WAL-safe = the three store files together):
     `STAMP=$(date -u +%Y%m%dT%H%M%SZ); DEST="$S/Backups/safety-copies/13r-u1-drill-$STAMP"; mkdir -p
     "$DEST"; cd "$S" && for f in variorum.sqlite variorum.sqlite-wal variorum.sqlite-shm
     variorum-keys*.json; do cp -p "$f" "$DEST/" && cmp "$f" "$DEST/$f" && echo "ok $f"; done` →
     expect SIX `ok` lines: the store, `-wal`, `-shm`, and three key files, as at staging and at
     18o's refresh. A different count: list it and decide before going on.
     - This drill's two extras: `cp -p "$C/Data/Library/Preferences/io.lduarte.Variorum.plist"
       "$DEST/"` (UserDefaults, where the backup-folder bookmark lives) and `cp -p
       "$C/.com.apple.containermanagerd.metadata.plist"
       "$DEST/containermanagerd.metadata.BEFORE.plist"`. These are evidence; restoring them is the
       orchestrator's call.
   - **2. Mark the window [O]:** `START=$(date '+%Y-%m-%d %H:%M:%S')`; `plutil -p
     "$C/.com.apple.containermanagerd.metadata.plist" | grep Owners` (record it).
   - **3. Reveal [O]:** `open -R "$APP"`, which shows the bundle in Finder for her.
   - **4. THE ONE LAUNCH [HER].** Double-click `Variorum.app` in that Finder window (or run `open
     "$APP"`).
     - EXPECTED: the window reads "Variorum" (not "Variorum Dev"). If her posture is Biometric,
       ONE Touch ID prompt (the custody read lands). Then HER library, the same notes as her daily
       drive.
     - Look only: open one recent note; edit nothing; change no setting; do not sign in or out; do
       not open a reference.
     - OPTIONAL, read-only: Settings ▸ Data Safety. Note whether the backup-folder line reads
       normally or says the folder can't be found (the bookmark observation above).
     - Then ⌘Q.
   - **4-STOP. Any of these: give the NON-granting answer, quit, report, do nothing else.**
     - A "Variorum would like to access data from other apps" prompt → **Don't Allow** (predicted
       silent).
     - A keychain PASSWORD prompt ("…wants to use your confidential information…") → **Deny**
       (predicted impossible, step 0d).
     - Instead of her library: a custody refusal, an unlock or "set up" screen, an EMPTY library,
       or any error → quit WITHOUT pressing any door on it. That visible refusal is exactly what
       the `CustodyHandover` guard exists to show; the A1 copy restores.
     - Touch ID asked more than once, or a passphrase request she does not expect → Cancel, quit.
   - **5. [O]** `pgrep -fl 'Variorum.app/Contents/MacOS'` → no output (zero instances again).
   - **6. Verification reads [O], all read-only.**
     - (a) `log show --start "$START" --predicate 'processImagePath CONTAINS "drill.noindex"'
       --info --style compact`: the drill process's own lines, the `protection` / `e2ee`
       categories among them. Then `log show --start "$START" --predicate 'processImagePath
       CONTAINS "drill.noindex" AND (eventMessage CONTAINS "-34018" OR messageType == error)'` →
       expect nothing custody-shaped. `-34018` = errSecMissingEntitlement = the group failure the
       drill exists to rule out.
     - (b) `plutil -p "$C/.com.apple.containermanagerd.metadata.plist" | grep Owners` versus step
       2: record the change. A second owner entry with `validationCategory` developer-id is a FACT
       to record, not a failure.
     - (c) Step 0(d)'s sweep again → still all `none`.
     - (d) `$LSR -u "$APP"` (the launch re-registers it), then `$LSR -dump | grep -c
       'drill.noindex'` → `0`.
   - **7. THE RETURN LEG [HER].** Open `/Applications/Variorum.app` as she always does. It must
     open exactly as before: Touch ID as usual, NO new prompt, her library. This proves the
     Developer ID launch re-owned nothing her daily build needs. The same 4-STOP rules apply.
   - **8. VERDICT [O], into this record.** PASS = all of the following:
     - the custody read landed (at most her posture's one Touch ID);
     - the library opened;
     - no unexpected prompt;
     - no `-34018` or custody refusal in 6(a);
     - the return leg was clean.

     PASS closes the KnownIssues keychain-access-groups row (24) at the phase close.
   - **ROLLBACK (only on a FAIL, at zero instances) [O]:** copy the six store and key files from
     `$DEST` back over `$S` with `cp -p`, then `cmp` each. That is the established A1 restore. The
     prefs/metadata copies are evidence: restoring them (cfprefsd caches prefs) is the
     orchestrator's call, with her.

**THE LIVE DRILL VERDICT (the orchestrator, 2026-10-04, the drill sitting — step 8): PASS, all
five arms. U1 IS CLOSED.**
- **Her launch** (04:31:05 local, PID 84420, the CDHash-named build; preconditions 0a–0d all
  green minutes before, the A1 rail's six `ok` lines + two evidence extras at
  `safety-copies/13r-u1-drill-20261004T102619Z`): ONE Touch ID — her words, *"it needed touch
  id to oepn, I opened it, looks fine"* — then HER library, the window reading "Variorum". The
  custody read landed; no 4-STOP rule fired; she looked only and ⌘Q'd.
- **The logs (6a):** 4,096 lines from the drill process; **ZERO `-34018`**
  (errSecMissingEntitlement — the group failure the drill exists to rule out); the only
  error-typed lines are three stock macOS benignities (the `/private/var/db/DetachedSignatures`
  sqlite probe, a BaseBoard task-port line, a ViewBridge teardown that labels itself benign).
  (Harness note for successors: `log` is a zsh BUILTIN in this shell — call `/usr/bin/log`.)
- **Owners (6b): BYTE-UNCHANGED** — still the single development entry. The predicted-silent
  container access confirmed, and stronger: the Developer ID launch added no second owner entry
  at all.
- **The keychain sweep (6c):** all five services still `none` in the legacy keychain — nothing
  migrated or created there. **LaunchServices (6d):** re-registration removed, dump count 0.
- **The return leg (7):** her daily `/Applications` build — her words, *"opened normally,
  looks good."* Undisturbed.
- **BONUS — the staged bookmark observation landed GOOD:** Settings ▸ Data Safety in the drill
  build rendered her second backup folder (`~/Desktop/mybackups/`) normally, copy counts and
  dates showing (her screenshot) — the app-scope bookmark RESOLVED under the new signature;
  the community-reported failure did not occur. Both of the staging's UNCONFIRMED predictions
  (container silence, bookmark survival) are now CONFIRMED on the clean side.
- The A1 copies stay per the rail's custom; the prefs/metadata extras were evidence only,
  nothing restored. **PASS authorizes the KnownIssues keychain-access-groups row-24 flip at
  the phase close.**

---

## U2 RECORD (the implementer's LIVE STATUS — Opus, 2026-10-04; DONE(hash) / IN-PROGRESS / PENDING)

**NOT DONE BY THIS UNIT (stated first, per the contract; FINAL at the session's stop):**
- **THE WALK (R-13r-8), U2's acceptance:** STAGED (piece 6's checklist W-0…W-10), never run by this
  session. **U2 does not close until her walk's VERDICT lands here.**
- **`make-appcast.sh`'s first LIVE run** reads HER Keychain, so it is the walk's step W-0(c),
  staged and never run here. `verify-appcast.swift` was exercised only on a synthetic feed signed
  with a THROWAWAY key. Every other pipeline step ran for real, twice (walk A + walk B).
- **No public release, no publish:** nothing went to `dl.stargazing.tech` or the public feed (it
  answers 404). `verify-published.sh` ran against nothing live.
- **Suites:** the full Mac and core suites were NOT run, because the brief names none. The targeted
  closing check is under piece 4's "Verified" (the U2 pins + every menu/registry suite that reads
  `EditorCommands`). The ladder's "suite green" is the phase's.
- **HER HANDS step 3 (the EdDSA minting) was HERS:** staged as command text (piece 3), then run by
  her (recorded at `b66633a9`). This session never ran `generate_keys` in any form and never
  handled the private key or the `-x` export.
- Out of scope, untouched: zero `Sync/`, zero schema, no editor seam, `/Applications` never touched,
  the real store never touched, no custom build configuration, nothing against the public feed.
  MARKETING_VERSION and the build-number stamping build phase are U3's (R-13r-6), so this unit
  leaves them as they are.

**U2 STATE (2026-10-04): ALL SIX PIECES DONE, and THE WALK IS STAGED, AUTHOR-GATED.** The session
stops here and reports, and the orchestrator coordinates her sitting.
- **What remains for U2 to close:** HER walk (piece 6's checklist), INCLUDING W-0(c), the
  pipeline's one Keychain step (`make-appcast.sh`'s first live run). Then the VERDICT lands in this
  record.
- (History: paused after piece 3 for HER HANDS step 3. The minting was recorded at `b66633a9`, and
  pieces 4–6 resumed with the public key.) **Toolchain re-read at session
start: matches the pinned pair** — macOS 27.0 (26A428) · Xcode 27.0 (27A266a) · `xcode-select -p` =
`/Applications/Xcode.app/Contents/Developer`. Zero-instance check
(`pgrep -fl 'Variorum.app/Contents/MacOS'`): no match. HEAD `dd95e301`, tree clean, commit count 4815.

**Pieces:**
1. **Sparkle 2.10.0 via SPM, the Mac target ONLY** — DONE (`0d2f7d78`; the builds verified below).
   - `project.pbxproj`: ONE `XCRemoteSwiftPackageReference "Sparkle"`
     (`https://github.com/sparkle-project/Sparkle`, `requirement = { kind = exactVersion; version =
     2.10.0; }` — EXACT, never a range), ONE `XCSwiftPackageProductDependency` (`Sparkle`) in the
     **Variorum** target's `packageProductDependencies` + its Frameworks phase. The VariorumMobile
     target, the test targets and `Shared/` are untouched: no `Sparkle` line names them.
   - `xcodebuild -resolvePackageDependencies` (exit 0, log `App/Variorum/DerivedData/13r-u2/resolve.log`):
     `Sparkle: https://github.com/sparkle-project/Sparkle @ 2.10.0`; `Package.resolved` gains the one
     pin `sparkle` → `version 2.10.0`, `revision eef1a539a373c1f1a320624b1130fc5de7b2e100` (the
     checkout's `git describe --tags` = `2.10.0`). No other pin moved.
   - **The Mac app builds CLEAN:** `xcodebuild -scheme Variorum -destination 'platform=macOS'
     -configuration Debug -derivedDataPath App/Variorum/DerivedData/13r-u2/debug build` (a fresh
     path) → `** BUILD SUCCEEDED **`, exit 0. **The warning set is IDENTICAL to U1's post-fix
     baseline** (`13r-u1/fix-xcodebuild-debug.log`): 28 unique warnings on each side, `diff` empty.
     Sparkle adds no warnings. The bundle embeds `Contents/Frameworks/Sparkle.framework` (2.10.0),
     whose `Versions/B/` carries `Autoupdate`, `Updater.app` and `XPCServices/{Installer,Downloader}.xpc`.
     Sparkle 2.6+ ships its XPC services INSIDE the framework, so no copy phase is needed; piece 4
     enables only the Installer road (`SUEnableInstallerLauncherService`), never the Downloader.
   - **The mobile target is unaffected:** `xcodebuild -scheme VariorumMobile -destination
     'generic/platform=iOS Simulator' … build` → `** BUILD SUCCEEDED **`; ZERO `*sparkle*` paths
     inside the built `VariorumMobile.app` (log `13r-u2/build-mobile.log`).
2. **Sparkle's official command-line tools (the 2.10.0 release artifact)** — DONE (this commit).
   - **The road:** `Tools/Release/fetch-sparkle-tools.sh` (`--path` prints the bin dir). It
     downloads `Sparkle-2.10.0.tar.xz` from the GitHub release, REFUSES unless the tarball's sha256
     equals the pin, extracts only `./bin` + `./LICENSE`, and REFUSES unless every tool's sha256
     equals its own pin and `codesign --verify --strict` passes. Idempotent: a present, verified
     copy is re-verified and left alone. It NEVER runs a tool.
   - **Where they land:** `Tools/Release/vendor/Sparkle-2.10.0/bin/` (gitignored, new
     `.gitignore` line `Tools/Release/vendor/`). Binaries never enter the repo.
   - **The checksums (pinned in the script):**
     - tarball `Sparkle-2.10.0.tar.xz` (16,319,840 bytes) sha256
       `c2bf58aa8387266ac179357b1415d6f2635f044da8be41042af32425dae6da0c`. This equals the digest
       GitHub's release API publishes for that asset (uploader `Sparkle-Bot`; release published
       2026-09-13T23:54:06Z, not a draft or prerelease).
     - `generate_keys` `c37679f98d9121981cf7b2d18592fdc8b44931bffa604acf10c9e11791b6222e`
     - `generate_appcast` `59e48e8432433cf4358519027e67e2c66a7348e0fe415f75f67b3b2372c13844`
     - `sign_update` `43c249771bafc3aa581228abae00731a012d324691b8292860896635050be76b`
     - `BinaryDelta` `020adbe773efb0e53e4146d805e37a72e9ceee25c993b7ff6c86c4bb4f9f90b3`
   - **A FACT the brief's word "signed" needs corrected:** Sparkle ships these tools **AD-HOC
     signed** (`flags=0x10002(adhoc,runtime)`, `TeamIdentifier=not set`). The framework is also
     ad-hoc in the release; the export re-signs it under her Developer ID. So no Developer ID
     vouches for the tools. Their authenticity is the release artifact's, and two INDEPENDENTLY
     checksummed roads agree on every byte:
     - the tarball's GitHub-published digest;
     - the SPM artifact Xcode downloaded. `Package.swift` at the tag (revision `eef1a539`) pins
       `checksum = 17e28312b8e18ab7cdbbe09a6fb28cc55a5479ec6c371dbc07cdecd2a14fd959`, which is also
       GitHub's published digest for `Sparkle-for-Swift-Package-Manager.zip`. SPM verifies it at
       download. That zip's `bin/` tools are **BYTE-IDENTICAL** to the tarball's, all four measured.
   - **Verified:** the first run installed; the second run reported "present and verified". A
     NEGATIVE run (a copy of the script with a zeroed tarball pin, in the scratchpad) REFUSED with
     exit 1 and installed nothing.
   - **One keychain fact for the runbook:** the ad-hoc identity is the binary's cdhash. When the
     pipeline's `generate_appcast` first reads the key `generate_keys` created, macOS asks HER once.
     The prompt reads "generate_appcast wants to use your confidential information stored in
     'https://sparkle-project.org'": login password, then Allow or Always Allow. A future tools
     upgrade (a new cdhash) asks again.
3. **HER minting commands, staged** — DONE (this commit). **→ HARD PAUSE** (commit, push, report;
   the orchestrator carries the minting to her and returns the PUBLIC key string).

   **What was established before staging (read-only; nothing run):**
   - `generate_keys`' behaviour was READ FROM ITS SOURCE at the tag
     (`SourcePackages/checkouts/Sparkle/generate_keys/main.swift`), never by running it:
     - The key is a generic-password item in the LOGIN keychain: service
       `https://sparkle-project.org`, account `ed25519` (the default; R-13r-1 takes the default), label
       "Private key for signing Sparkle updates". The item's comment carries the PUBLIC key.
     - Default mode (no flags) MINTS only when no item exists. Otherwise it REUSES the existing key
       and prints "A pre-existing signing key was found".
     - `-p` prints ONLY the base64 public key.
     - `-x <file>` writes the base64 private SEED to `<file>` (32 bytes → 44 base64 characters, no
       newline) and refuses if `<file>` exists.
   - **No pre-existing Sparkle key exists**, checked by ATTRIBUTES ONLY (U1's step-0(d) precedent;
     never `-g`): `security find-generic-password -s https://sparkle-project.org` → none, and by
     label → none. So her run MINTS a fresh key, as R-13r-1 assumes. It cannot silently reuse
     another project's key.

   **THE STAGED COMMANDS — HER HANDS step 3.** Run them in HER Terminal (her session, login keychain
   unlocked), one block at a time. Only the public-key line ever leaves her machine.
   ```sh
   # 0. Re-verify the tools by digest right before running one (must say "present and verified").
   cd <home>/dev/variorum && Tools/Release/fetch-sparkle-tools.sh
   T=<home>/dev/variorum/Tools/Release/vendor/Sparkle-2.10.0/bin

   # 1. MINT. Expected: "Generating a new signing key…", then "A key has been generated and saved in
   #    your keychain" with an <key>SUPublicEDKey</key> block. If it instead says "A pre-existing
   #    signing key was found": STOP and report (none existed at staging). If macOS asks to allow
   #    saving to the keychain: Allow.
   "$T/generate_keys"

   # 2. THE PUBLIC KEY: one line, 44 characters ending in "=". THIS line (and only this) goes back to
   #    the orchestrator. It is public: it ships in every app bundle.
   "$T/generate_keys" -p

   # 3. THE ONE BACKUP (R-13r-1). The export goes to her private per-user temp folder (not synced,
   #    not in the repo). Expected output: nothing, then "44" (the seed's length, which reveals nothing).
   EXPORT="$TMPDIR/variorum-sparkle-key-export.txt"
   "$T/generate_keys" -x "$EXPORT" && wc -c < "$EXPORT"
   ```
   **4. Into her password manager.** Create ONE item, e.g. "Variorum — Sparkle update-signing key
   (generate_keys -x backup)".
   - **The secret:** if the manager takes file attachments, attach `$EXPORT`. Otherwise run
     `pbcopy < "$EXPORT"`, paste into the item's password/secret field, then clear the clipboard
     at once with `pbcopy < /dev/null` (Universal Clipboard can relay to her nearby devices
     meanwhile).
   - **The item's notes:** the step-2 public key, the date, and "import with: generate_keys -f
     <file>". The notes let a future restore be checked against the shipped `SUPublicEDKey`.
   ```sh
   # 5. Remove the export and confirm the key stays in her login keychain (attributes only, no secret).
   rm "$EXPORT"; pbcopy < /dev/null
   ls "$EXPORT" 2>/dev/null || echo "export removed"
   security find-generic-password -s https://sparkle-project.org -a ed25519 >/dev/null && echo "key in login keychain"
   ```
   **STOP rules.**
   - A "pre-existing key" message at step 1, an error from any step, or a `wc -c` other than 44:
     stop, run nothing further, report.
   - The export file NEVER goes into the repo, a chat, an email, iCloud Drive or a synced folder.
   - The private key is NEVER typed or pasted anywhere but the password-manager item.

   **What returns to this session:** the step-2 PUBLIC key string, and nothing else. Piece 4 bakes it
   as `SUPublicEDKey`.

   **Rotation, if ever needed (her R-13r-1 leak story; not run now):** per R-13r-1's record, rotation
   rides a Developer-ID-signed DMG transition update (Sparkle's documented road). The backup is what
   keeps ORDINARY signing available after a lost or wiped machine (`generate_keys -f` re-imports it),
   so no transition is needed for that case.

   **U2 STATE AT THE PAUSE:** pieces 1–3 DONE and pushed. The session STOPS here and reports. **Piece
   4 resumes ONLY with the public key in hand.** Nothing is uncommitted. No build or suite is running.

   **HER HANDS STEP 3 — DONE (2026-10-04, the minting sitting, her hands via the `!` road, every
   output witnessed by the orchestrator):** the mint printed "A key has been generated and saved in
   your keychain" (fresh, as staged — no pre-existing-key message); **the PUBLIC key =
   `tn/IQUaJMGk8Q+T8iE3ph2t+xpdzlUDGxg7+k/5xMhA=`** (44 chars, the `-p` cross-check byte-identical);
   the backup export wrote 44 bytes and went to her password manager (step 4, her GUI;
   **stow CONFIRMED at her word — "yes" — before any further step**, so R-13r-1's one-backup
   custody stands complete); the export file REMOVED —
   with one wrinkle caught: the first cleanup ran with an empty `$EXPORT` (the `!` road starts a
   fresh shell per command, so the variable did not persist and `rm` deleted nothing while the
   `ls`-based echo misleadingly said "removed") — re-run with the path set inline: `removed` +
   `gone for real`, witnessed. The keychain attributes check confirmed the key in her login
   keychain. **Lesson for every staged her-hands block: `!`-road commands get NO shared shell
   state — every block must set its own variables inline.** Piece 4 resumes with the key.
4. **After the public key:** the partial Info.plist (`SUPublicEDKey`, `SUFeedURL`,
   `SUEnableInstallerLauncherService`), the two mach-lookup exceptions, the non-DEBUG updater
   with Sparkle's standard consent flow, the Check for Updates… door — **DONE** (`e4694ac2` +
   `0903f125`, the mutation check recorded in this commit).

   **Sparkle facts READ FROM THE 2.10.0 SOURCE in the checkout (`SourcePackages/checkouts/Sparkle`,
   tag 2.10.0), not assumed:**
   - **The walk's feed override works.** `SPUUpdater.retrieveFeedURL` reads
     `[_host objectForKey:SUFeedURLKey]`, and `SUHost objectForKey:` returns the USER-DEFAULTS
     value before the Info.plist one. Sparkle's own start-up warning about a defaults feed URL ends
     "If the feed url was set via a defaults write command for testing purposes, then please ignore
     this warning."
   - **The consent flow** (`SPUUpdater startUpdateCycle`):
     - With `SUEnableAutomaticChecks` unset and no delegate override, Sparkle prompts when
       `SUHasLaunchedBefore` is already set. So the FIRST launch only sets that flag, and the
       SECOND launch asks ("Check for updates automatically?").
     - With automatic checks unanswered/off, `scheduleNextUpdateCheckFiringImmediately:NO` returns
       without checking. **So no network call is made before she consents, unless she presses
       Check for Updates….**
   - **No system profile:** the permission prompt's "Include anonymous system profile" control is
     gated on the Info.plist `SUEnableSystemProfiling` (`SUUpdatePermissionPrompt.m:78`), which is
     left unset.
   - **An http feed is not refused:** with an EdDSA key present, Sparkle only LOGS an ATS warning
     ("If the feed URL is using local networking for testing, this warning may be incorrect"). The
     OS's ATS is the separate question (piece 6).
   - **DMG updates work on the sandboxed road:** the disk image is unpacked by
     `Autoupdate/SUDiskImageUnarchiver` inside the installer, which runs outside the sandbox.
   - **The XPC services must live INSIDE Sparkle.framework, never in the app.** Sparkle refuses an
     app-level `Contents/XPCServices/Installer.xpc`, and SPM's framework layout satisfies this.
     Separately, `SUInstallerLauncher` logs "make sure InstallerLauncher is not sandboxed and do
     not sign your app by passing --deep". Xcode's export never passes `--deep`; piece 5's check
     reads the Installer's entitlements.
   - **Sparkle refuses an app running from a read-only or temporary location**
     (`SPUBasicUpdateDriver`, `SURunningFromDiskImageError`): "can't be updated because it was opened
     from a read-only or a temporary location". So the walk installs by a FINDER DRAG into
     `~/Applications`, which also clears Gatekeeper's App Translocation.
   - API (`SPUStandardUpdaterController.h`): `initWithStartingUpdater:updaterDelegate:userDriverDelegate:`,
     `startUpdater`, `checkForUpdates:`; `SPUUpdater.canCheckForUpdates` is the documented
     KVO-observable for menu enablement.

   **What landed (this commit):**
   - **`App/Variorum/VariorumInfo.plist`:**
     - `SUPublicEDKey` = `tn/IQUaJMGk8Q+T8iE3ph2t+xpdzlUDGxg7+k/5xMhA=`;
     - `SUFeedURL` = `https://stargazing.tech/variorum/appcast.xml` (the LOCKED URL);
     - `SUEnableInstallerLauncherService` = YES.
     - The comment records the three deliberate ABSENCES: automatic checks, system profiling, the
       downloader service.
     - The file is shared by both configurations and INERT in Debug, because nothing instantiates
       Sparkle there.
   - **`App/Variorum/Variorum.entitlements`:** `com.apple.security.temporary-exception.mach-lookup.global-name`
     = [`$(PRODUCT_BUNDLE_IDENTIFIER)-spks`, `$(PRODUCT_BUNDLE_IDENTIFIER)-spki`]. It is the
     variable form, exactly as the keychain groups.
   - **`Variorum/Features/Updates/UpdateChannel.swift`:** a NEW Mac-only module (never `Shared/`;
     the mobile target cannot see Sparkle).
     - `@Observable final class UpdateChannel`. THE FENCE is ONE constant, `liveInThisBuild`
       (`#if DEBUG` → false), consulted only in `forThisBuild()`. Only INSTANTIATION is fenced, so
       the Sparkle-touching code compiles in Debug too, and a Debug build type-checks the Release
       road.
     - A live channel builds `SPUStandardUpdaterController(startingUpdater: false, …)` with no
       delegates (Sparkle's standard user driver and consent flow). `start()` starts it and KVO-mirrors
       `canCheckForUpdates`. `checkForUpdates()` is the door's act.
   - **`VariorumAppDelegate`:** `let updates = UpdateChannel.forThisBuild()` (the
     `AppearanceController` precedent: one per app, exists before the first window), and
     `updates.start()` in `applicationDidFinishLaunching`.
   - **The door:** `EditorCommands` gains `updates`, and `CommandGroup(after: .appInfo)` renders
     **Variorum ▸ Check for Updates…** ONLY when `updates.isLive`, disabled while
     `!canCheckForUpdates`.
     - P-2: never rendered in Debug, where it could never act.
     - UNDECLARED in the capability registry, on the "Lock Library Now" / "New Window" precedent:
       an app-menu standard, conditionally rendered, with no block/take/post/book scope.
       **Flagged for the ladder** as a P-1 reading, not a product call.
   - **The only chrome face is the menu item.** Every update window (consent, found, progress,
     relaunch) is Sparkle's own standard UI, not this unit's to re-voice.
   - **The pins:**
     - `VariorumTests/UpdateChannelTests.swift`: the Debug fence at both levels; the inert channel's
       no-door/no-op contract; the door's words; the locked feed URL; the minted public key (exact,
       and 32 bytes decoded); launcher ON / downloader absent; automatic checks, system profiling
       and prompt-on-first-launch ABSENT.
     - `EntitlementsTests` gains one pin: the mach-lookup names equal `[<bundleID>-spks,
       <bundleID>-spki]` in the Debug host (`io.lduarte.Variorum.debug-…`).
     - **The fence pin gets NO mutation run, deliberately.** The mutant (a live channel in Debug)
       would START Sparkle in a Debug build pointed at the public feed, which is exactly what
       R-13r-7 forbids. The pin's red side holds by construction; the Release side is piece 5's
       export check + the walk.
   - **Verified:**
     - **Build:** a CLEAN Debug build (`-derivedDataPath App/Variorum/DerivedData/13r-u2/p4-debug`,
       removed first) → `** BUILD SUCCEEDED **`. The warning set is **IDENTICAL to the U1
       baseline, 28/28**. Two of my own warnings were met on the way and removed by design, not
       suppressed:
       - `SPUUpdater` imports into Swift as MAIN-ACTOR-ISOLATED (Sparkle's main-thread contract),
         so the KVO handler's read must sit on the main actor.
       - The handler now asserts that contract with `MainActor.assumeIsolated`. KVO fires on the
         mutating thread, which is main by Sparkle's contract, and `.initial` fires synchronously
         inside `observe`.
     - **The signed Debug bundle** (`codesign -d --entitlements -`) carries
       `mach-lookup.global-name = [io.lduarte.Variorum.debug-spks, io.lduarte.Variorum.debug-spki]`,
       so the variable form resolves per configuration. Its Info.plist carries the three keys, and
       the downloader and automatic-checks keys are absent.
     - **Pins:** `xcodebuild test … -only-testing:VariorumTests/UpdateChannelTests
       -only-testing:VariorumTests/EntitlementsTests -only-testing:VariorumTests/OneTimeCodeAutoFillTests`
       at a zero-instance window → **`Test run with 13 tests in 3 suites passed`**, no `skipped:`
       lines (log `13r-u2/p4-test2.log`).
       - The first run was RED on my own entitlement pin, and that was a TEST-HOST fact, not an app
         defect: when Xcode signs a test host it APPENDS `com.apple.testmanagerd`,
         `com.apple.dt.testmanagerd.runner` and `com.apple.coresymbolicationd` to this same array.
       - The pin now asserts that OUR two names LEAD, in order, and are the only Sparkle names. The
         piece-5 export check asserts EXACT equality on the shipped bundle, where nothing is
         injected.
     - **The mutation check (safe by construction: the Debug updater is never instantiated).**
       `SUFeedURL` was edited to `https://stargazing.tech/appcast.xml` (the committed state first, per
       the resiliency rule's commit-before-revert):
       - `UpdateChannelTests` went **RED, exactly 1 issue**
         (`theBakedFeedIsTheLockedStargazingURL`, `UpdateChannelTests.swift:57`).
       - Restored with `git checkout --`, then **GREEN, 7/7**; the tree is clean.
     - **Release-path compile:** the Sparkle-touching code compiles in Debug too (only instantiation
       is fenced), so the Debug build above type-checks it. Piece 5's archive is the Release proof. (Walk builds A and B archived Release
       clean, piece 5.)
     - **The closing check (the session's end, a zero-instance window):** `xcodebuild test …
       -only-testing:` CapabilityRegistryTests, ShellChromeTests, OpenStripMenuTests,
       ChordLegibilityTests, UpdateChannelTests, EntitlementsTests, OneTimeCodeAutoFillTests (plus
       a `WindowsTests` id that matched no suite) → **`Test run with 60 tests in 7 suites passed`**,
       0 `skipped` lines (log `13r-u2/close-suites.log`). The suites: the registry walk (P-1's
       declared ⇔ rendered), the flat shell, the merge chord, the Open strip's menu, the update
       channel, the entitlements, and one-time-code. The undeclared Check for Updates… door
       breaks none of the menu's source-reading pins.
5. **The full release pipeline** in `Tools/Release/` — **DONE** (`40301c3c` + `470c3ffc`). Two real
   runs PASSED end to end, every step but the Keychain one: walk A and walk B below. **One leg is
   left PENDING by design:** `make-appcast.sh`'s first live run reads HER Keychain, so it is the
   walk's step W-0(c), with her at the machine.

   **Two walk facts MEASURED first** (they shape both pieces 5 and 6). The probe was a throwaway
   SANDBOXED probe app: `network.client`, NO ATS dictionary, built against SDK 27.0 with `minos`
   26.0, its own bundle id `io.lduarte.u2-ats-probe`, run on this macOS 27.0. It touched no Variorum
   container. Its prefs and container were REMOVED after, verified absent.
   - **ATS allows loopback, and ATS was proven ACTIVE.** `http://localhost:8765/…` and
     `http://127.0.0.1:8765/…` both loaded (HTTP 200) from a local `python3 -m http.server`. The
     CONTROL, `http://example.com/`, FAILED with `NSURLErrorDomain -1022` ("…App Transport Security
     policy requires the use of a secure connection").
     - So the walk's locally-served plain-HTTP feed needs NO Info.plist exception, and **the walk
       builds are byte-for-byte the shipping configuration**.
     - The lookup's doc reading (macOS 14+ blocks IP literals by default) did not hold for
       loopback here. Measured beats inferred, and both are recorded.
   - **A sandboxed app's defaults are reached ONLY by the CONTAINER-PATH `defaults write`.** With
     the plain bundle id (`defaults write io.lduarte.u2-ats-probe SUFeedURL …`), the write landed in
     `~/Library/Preferences/` and the sandboxed app read **nil**. With the container path
     (`defaults write ~/Library/Containers/<id>/Data/Library/Preferences/<id> SUFeedURL …`), the app
     read it. The lookup's inference from `defaults read` was WRONG for writes.
     - The container exists only after the app's FIRST launch, so the walk's override comes after
       a first run and a quit.

   **THE PIPELINE (`Tools/Release/`, this commit; its first REAL run is next — PENDING):**
   - **`release.sh [--walk] --version X.Y.Z [--out DIR] [--stop-before-appcast]`** runs the whole
     order, refusing to continue on any failure:
     - **0. preflight:** a CLEAN tree (a build is one commit's), ZERO instances (pgrep, never quits
       one), the tools verified by digest, the `VariorumNotary` credential answers (`notarytool
       history`). Release mode also requires the version unpublished: no local record or feed copy,
       and `dl.stargazing.tech` answering **404** for that exact name.
     - **1. stamp:** MARKETING_VERSION = `--version`, CURRENT_PROJECT_VERSION =
       `git rev-list --count HEAD` (R-13r-6's number), passed as command-line overrides. There is no
       configuration.
     - **2. archive + export:** U1's `archive-and-export.sh`, REUSED and extended with `--version/--build`.
       Its drill must PASS with the stamp proven.
     - **3. notarize + staple the APP:** `ditto` zip → `notarytool submit --wait`. The JSON result
       and Apple's log are kept. Then staple + validate, and `verify-export.sh --require-notarized`
       must read Gatekeeper **ACCEPTED** with the ticket stapled.
     - **4. DMG:** plain `hdiutil` (UDZO, HFS+, the app + an `/Applications` link), named EXACTLY
       `Variorum-<version>.dmg`.
     - **5.** sign the DMG (Developer ID + timestamp).
     - **6.** notarize + staple the DMG; `spctl -t open` must ACCEPT it as Notarized Developer ID.
     - **7. the SHIPPED bytes:** mount the final DMG read-only and run `verify-export.sh
       --require-notarized` on the app INSIDE it.
     - **8. dSYMs:** copied out with their UUIDs proven equal to the shipped binary's. Release mode
       files them DURABLY in `~/Library/Developer/Variorum/Releases/<version>/` with the notary
       JSON and the verify reports, never in DerivedData, which gets swept.
     - **9. appcast:** `make-appcast.sh`.
     - **10. the HANDOFF,** printed and written to `HANDOFF.txt`.
   - **`make-appcast.sh (--release|--walk) --dmg … --version … --build …`** is the one step that
     reads HER Keychain, so it is separable (`--stop-before-appcast` + the printed resume line).
     - It refuses: a DMG not named exactly; an unstapled DMG; a feed name already holding DIFFERENT
       bytes (IMMUTABILITY); a walk DMG in the release feed, or the reverse.
     - It runs `generate_appcast --maximum-deltas 0 --download-url-prefix …`. Release mode uses the
       durable `~/Library/Developer/Variorum/Releases/feed` with `https://dl.stargazing.tech/variorum/`;
       walk mode uses the gitignored `App/Variorum/DerivedData/walk-feed` with `http://localhost:8765/`.
     - It then unregisters and REMOVES the real-store-id `Variorum.app` copy that generate_appcast
       extracts into `~/Library/Caches/Sparkle_generate_appcast` (U1's LaunchServices hazard,
       extended; other apps' cache entries are untouched).
     - Last it runs `verify-appcast.swift`.
   - **`verify-appcast.swift`** checks the new item with CryptoKit, independently of Sparkle:
     - shortVersionString;
     - the enclosure url = prefix + the exact DMG name;
     - the length = the DMG's bytes;
     - `sparkle:edSignature` VERIFIES over the DMG under the BAKED `SUPublicEDKey`, the end-to-end
       proof the Keychain's private key is the shipped key's twin;
     - the build is STRICTLY the feed's highest;
     - no deltas.
     **Exercised on a synthetic feed signed with a THROWAWAY CryptoKit key (never hers):** a valid
     item PASSES 7/7. A tampered DMG, her real key against the test signature, and a wrong
     version/prefix/length/non-highest build each FAIL, the last case with 5 issues.
   - **`verify-published.sh dmg|appcast`** covers the two publish-and-leave checks from this side:
     - `dmg`: one GET of the exact `dl.stargazing.tech` name, which must be sha256-IDENTICAL to the
       local DMG;
     - `appcast`: the live feed must be BYTE-IDENTICAL to the local `appcast.xml`, and the newest
       item's enclosure must already answer 200 with its declared length (the DMG-first order,
       checked from the far end).
     Today the live appcast answers 404, correctly: nothing is published.
   - **`verify-export.sh` + `archive-and-export.sh`** were extended in `815f7e38` (above in the
     commit log). Smoke on U1's pre-Sparkle export: EXACTLY the 7 Sparkle checks fail, and the other
     40 of 47 pass.

   **THE FIRST REAL RUN — WALK BUILD A, `0.0.1` (build 4829, commit `40301c3c`, a zero-instance
   window, `--stop-before-appcast`):** `Tools/Release/release.sh --walk --version 0.0.1
   --stop-before-appcast --out App/Variorum/DerivedData/13r-u2/walk-a` ran DETACHED, with its exit
   line in `13r-u2/walk-a.run.log`, and this session blocked on the log in foreground polls.
   `RELEASE-EXIT=0`, 12:54:18Z → 13:32:26Z.
   - **Preflight:** clean tree, zero instances, tools verified, `VariorumNotary` answered.
   - **Stamp → archive → export:** the export drill passed **56/56** with the stamp proven
     (`CFBundleShortVersionString 0.0.1`, `CFBundleVersion 4829`). Every nested Sparkle binary
     (`Autoupdate`, `Updater.app`, `Installer.xpc`, `Downloader.xpc`, the framework) was re-signed by
     the export under **Developer ID + hardened runtime + timestamp**. The keychain groups are
     byte-identical to her `/Applications` build. `Installer.xpc` is unsandboxed. The
     `-spks/-spki` pair is EXACT.
   *[removed for publication]*
     **Accepted**. Apple's log reads "Ready for distribution" with `issues: None`. **It sat "In
     Progress" ~32 minutes: the team's FIRST submission.** The DMG's submission took ~1 minute. Then
     `verify-export.sh --require-notarized` → **`PASS  Gatekeeper ACCEPTS (source=Notarized
     Developer ID)`** + **`stapler validate`** → **57/57**. This is U1's predicted turn from
     "rejected / Unnotarized Developer ID" to ACCEPTED, now measured.
   - **DMG:** `Variorum-0.0.1.dmg` (UDZO, the app + an `/Applications` link). Signed `Developer ID
     *[removed for publication]*
     *[removed for publication]*
     `spctl -a -t open --context context:primary-signature` → **accepted, source=Notarized
     Developer ID**.
   - **The SHIPPED bytes:** the app INSIDE the final DMG passed **57/57**. The DMG is **24,173,366
     bytes**, sha256 `beb771c211114bff58763aec6b18f371cd06c5ac0109311152e15b1ea590945f`.
   - **dSYMs:** `Variorum.app.dSYM` UUIDs = the shipped binary's (arm64 + x86_64:
     `9527D086-E84E-3D63-AFA4-4090B92E9F75`, `9A6AC251-79B8-3F6A-8571-128174AAE426`).
   - **A hygiene finding, FIXED in the road (this commit):**
     - **Finding:** after the run, LaunchServices again listed three paths under the run folder:
       the stapled export, the DMG's mount point, and Sparkle's `Updater.app` inside the archive
       intermediates. `archive-and-export.sh`'s own sweep had left 0, so the later steps that TOUCH
       the bundle (staple, Gatekeeper assessment, the mount) re-registered them.
     - **Fix:** `release.sh` now ends with a sweep. It deletes the archive's `DerivedData`
       intermediates (another full app copy, and **1.9 GB**; the dSYMs come from the `.xcarchive`),
       unregisters every `.app` under the run plus the mount's own record, and re-counts after a
       pause, listing only registrations whose path still EXISTS. A record for a removed mount point
       resolves nothing.
     - **Applied by hand to walk A: ZERO live registrations.**
     - **Spotlight measured CLEAN:** a global `kMDItemCFBundleIdentifier == "io.lduarte.Variorum"`
       query finds ONLY `/Applications/Variorum.app`, so `.noindex` holds. An `mdfind -onlyin` hit
       was a live scan of the folder named, not the index.
   - **The notarization wait cap is 6 h now (was 45 min),** because the first submission's 32
     minutes came too close.

   **WALK BUILD B, `0.0.2` (build 4830, commit `470c3ffc`, the hygiene fix aboard, a zero-instance
   window):** `RELEASE-EXIT=0` in ~6 minutes (13:34:35Z → 13:40:28Z), because both notarizations now
   return in about a minute.
   - The export drill passed 56/56.
   *[removed for publication]*
     **57/57 with Gatekeeper ACCEPTED**.
   *[removed for publication]*
   - **The shipped bytes passed 57/57.** `Variorum-0.0.2.dmg` is **24,173,312 bytes**, sha256
     `115b2c9def7d97be53daa432dc30e161053a00afe025539c6314f41dfd73d90e`.
   - dSYM UUIDs match (`27E03119-DAFF-3A0B-A667-E64A32F914F1`, `F21F8EE3-8930-3457-9E6A-4116EA221EB4`).
   - **The new final sweep, inside the script: `LaunchServices: 0 registrations` (the
     intermediates removed).** `archive-and-export.sh` had warned of 1 mid-run, and the final sweep
     cleared it.
   - **The update is real:** walk A's 4829 < walk B's 4830, because B was built from the later commit.
     Both DMGs re-validated (`stapler validate` → "The validate action worked!").
   - **Interface note for U3:** the pipeline passes the stamp as command-line overrides, and
     `verify-export.sh --expect-version/--expect-build` asserts it on the export. When U3's
     every-build stamping phase lands, it writes the SAME `git rev-list --count HEAD`, so the
     assertion still holds. U3 may then drop the `CURRENT_PROJECT_VERSION` override and keep the
     assertion, or keep both. U3's release notes plug in as a `Variorum-<version>.html|md` beside the
     DMG in the feed directory (generate_appcast picks it up, read from its source).
   - **A hazard note for the orchestrator (R-13r-7's premise):** her daily-drive builds carry
     CFBundleVersion **1** until U3's stamping lands (the project's `CURRENT_PROJECT_VERSION = 1`).
     A PUBLIC appcast entry must therefore not exist before U3's stamping is in her hand-copied
     build, or her own app would be OFFERED that release. Today the public feed answers 404, and the
     first release follows U3, so this is a sequencing fact, not a defect.
   - **A second hazard note:** her daily drive, refreshed after U2/U3, will show Sparkle's
     standard consent prompt ONCE, on its second launch. That is the standard flow, consistent with
     R-13r-7's "the check runs and offers nothing".
6. **The walk, staged** ([O]/[HER] checklist, the local feed plan, two walk builds) — **DONE:
   STAGED, never run** (this commit). The orchestrator coordinates her sitting. **U2 then closes on
   the walk's VERDICT** (the acceptance is USE).

   **THE WALK (R-13r-8) — the checklist.**
   - **Who does what:** `[O]` = the orchestrator, in HER session (shell). `[HER]` = her hands.
   - **The `!`-road lesson binds:** every command block run in her session sets its own values
     inline. No variable carries between commands.
   *[removed for publication]*
   *[removed for publication]*
     *[removed for publication]*
   - **The artifacts (built and verified above):**
     - walk A `App/Variorum/DerivedData/13r-u2/walk-a.noindex/Variorum-0.0.1.dmg` (the version she
       installs);
     - walk B `App/Variorum/DerivedData/13r-u2/walk-b.noindex/Variorum-0.0.2.dmg` (the update);
     - the walk feed `App/Variorum/DerivedData/walk-feed/`, served at `http://localhost:8765/`.
       *[removed for publication]*
       plain-HTTP loopback (measured, piece 5).
   - **The walk builds ARE the shipping configuration:** the same Info.plist (the LOCKED public feed
     baked in), the same entitlements. The ONLY walk-specific thing is a user default written into
     *[removed for publication]*
     public feed (R-13r-7/8).

   - **W-0. Preconditions** (her session, before she switches).
     - **(a) [HER]** quits her Variorum. **[O]** `pgrep -fl 'Variorum.app/Contents/MacOS'` → NO
       *[removed for publication]*
       confuse the discipline even across stores (ENVIRONMENT TRAPS).
     - **(b) [O]** Both walk DMGs still verify:
       ```sh
       cd <home>/dev/variorum && for d in App/Variorum/DerivedData/13r-u2/walk-a.noindex/Variorum-0.0.1.dmg App/Variorum/DerivedData/13r-u2/walk-b.noindex/Variorum-0.0.2.dmg; do xcrun stapler validate "$d" | tail -1; spctl -a -t open --context context:primary-signature -vv "$d" 2>&1 | head -2; shasum -a 256 "$d"; done
       ```
       Expect "The validate action worked!", "accepted / source=Notarized Developer ID", and the
       sha256s recorded above (A `beb771c2…`, B `115b2c9d…`).
     - **(c) THE WALK APPCAST — the ONE Keychain step: [O] runs it, [HER] approves.**
       ```sh
       cd <home>/dev/variorum && Tools/Release/make-appcast.sh --walk --dmg App/Variorum/DerivedData/13r-u2/walk-b.noindex/Variorum-0.0.2.dmg --version 0.0.2 --build 4830
       ```
       - The first run on this machine makes macOS ask HER: "generate_appcast wants to use your
         confidential information stored in “https://sparkle-project.org” in your keychain."
         **[HER]** enters her login password, then **Always Allow** (it asks again only after a
         Sparkle tools upgrade) or **Allow** (it asks at every release).
       - Expect `VERDICT: PASS`, with 7 PASS lines from `verify-appcast`. **This is the first proof
         that her Keychain's private key is the twin of the baked `SUPublicEDKey`** (the
         `edSignature` VERIFIES under it). The real-release signing road is proven here too.
       - The feed directory then holds `appcast.xml` + `Variorum-0.0.2.dmg` + the logs.
     - **(d) [O]** Serve the walk feed DETACHED, so it outlives the call and the user switch:
       ```sh
       cd <home>/dev/variorum/App/Variorum/DerivedData/walk-feed && nohup python3 -m http.server 8765 --bind 127.0.0.1 > <home>/dev/variorum/App/Variorum/DerivedData/13r-u2/walk-server.log 2>&1 < /dev/null & echo $! > <home>/dev/variorum/App/Variorum/DerivedData/13r-u2/walk-server.pid
       curl -s http://localhost:8765/appcast.xml | grep -c '<item>'
       curl -sI http://localhost:8765/Variorum-0.0.2.dmg | head -1
       ```
       Expect `1` and `HTTP/1.0 200 OK`.
     *[removed for publication]*
       exercised exactly as on a friend's machine:
       ```sh
       mkdir -p /Users/Shared/VariorumWalk/captures && chmod 1777 /Users/Shared/VariorumWalk/captures
       cp <home>/dev/variorum/App/Variorum/DerivedData/13r-u2/walk-a.noindex/Variorum-0.0.1.dmg /Users/Shared/VariorumWalk/ && chmod 644 /Users/Shared/VariorumWalk/Variorum-0.0.1.dmg
       xattr -w com.apple.quarantine "0083;$(printf %x $(date +%s));Safari;$(uuidgen)" /Users/Shared/VariorumWalk/Variorum-0.0.1.dmg
       xattr -p com.apple.quarantine /Users/Shared/VariorumWalk/Variorum-0.0.1.dmg; spctl -a -t open --context context:primary-signature -vv /Users/Shared/VariorumWalk/Variorum-0.0.1.dmg 2>&1 | head -2
       ```
       Expect a `0083;…;Safari;…` line, then "accepted / source=Notarized Developer ID".
     - **(f) [O]** `date -u +'%Y-%m-%d %H:%M:%S'`. Record it as the walk's START (for W-10's log read).

   *[removed for publication]*
     session keeps running, and the feed server with it.

   *[removed for publication]*
     ```sh
     mkdir -p ~/Applications
     defaults write com.apple.screencapture location /Users/Shared/VariorumWalk/captures
     *[removed for publication]*
     *[removed for publication]*
     ```
     *[removed for publication]*
     ⌘⇧3 screenshots land in the shared captures folder. If the location does not take, use
     ⌘⇧5 ▸ Options ▸ Other Location.

   - **W-3. [HER] Gatekeeper on the quarantined DMG:** Finder ▸ Go ▸ Go to Folder… →
     `/Users/Shared/VariorumWalk` → double-click `Variorum-0.0.1.dmg`.
     - EXPECT: macOS verifies the image, and the DMG window opens with `Variorum.app` and the
       `Applications` link. No warning blocks it.
     - **CAPTURE W1.**

   *[removed for publication]*
     - Open a second Finder window at Go ▸ Home ▸ Applications (the folder W-2 made). Drag
       `Variorum.app` from the DMG window INTO it.
     *[removed for publication]*
       That is expected, not a defect. A Finder DRAG also clears App Translocation. Sparkle refuses
       an app run from a read-only or temporary location (read from its source).
     - Eject the DMG.
     *[removed for publication]*
       ```sh
       *[removed for publication]*
       *[removed for publication]*
       ```
       Expect the quarantine INHERITED, then **accepted / source=Notarized Developer ID**. This is
       the plan's literal `spctl -a -vv` acceptance.

   - **W-5. [HER] FIRST LAUNCH:** double-click `~/Applications/Variorum.app`.
     - **The Gatekeeper dialog.** EXPECT the notarized-app question: "“Variorum” is an app
       downloaded from the Internet. Are you sure you want to open it?" (with Apple's
       checked-for-malicious-software line). Press **Open**. **CAPTURE W2.**
     - **A BLOCK dialog = STOP:** "cannot be opened because Apple cannot check it…", "is damaged",
       "unidentified developer".
     *[removed for publication]*
       first-run defaults appear. Sign in to NOTHING. **CAPTURE W3.** (The iCloud-Keychain waiting
       lobby cannot appear: it is only for an EXISTING encrypted store whose key is missing,
       `AppBootstrap` read at staging.)
     - **No consent yet.** EXPECT NO Sparkle consent prompt on this first launch. Sparkle asks on the
       SECOND launch (read from its source).
     - **The version.** Variorum ▸ About Variorum reads **0.0.1 (4829)**. **CAPTURE W4.**
     - **The door.** Open the Variorum menu: **Check for Updates…** sits under About. **CAPTURE W5**
       (the menu open). Do not press it yet.
     - **⌘Q.**

   *[removed for publication]*
     and the CONTAINER-PATH form is the ONLY one a sandboxed app reads (measured in piece 5: the
     plain bundle-id form writes where the app never looks):
     ```sh
     defaults write ~/Library/Containers/io.lduarte.Variorum/Data/Library/Preferences/io.lduarte.Variorum SUFeedURL http://localhost:8765/appcast.xml
     *[removed for publication]*
     ```
     Expect `http://localhost:8765/appcast.xml`. Sparkle reads a defaults `SUFeedURL` before the
     Info.plist one, and logs a warning that names "a defaults write command for testing purposes"
     as fine.

   - **W-7. [HER] SECOND LAUNCH → CONSENT:** open Variorum again.
     - EXPECT Sparkle's permission prompt: "Check for updates automatically?" with **Check
       Automatically** / **Don't Check**, and NO "Include anonymous system profile" option
       (`SUEnableSystemProfiling` is unset). **CAPTURE W6.**
     - Choose **Check Automatically**. If Sparkle then finds 0.0.2 on its own and shows the update
       alert, skip to W-8's second step.

   - **W-8. [HER] THE UPDATE:**
     - **Find.** Variorum ▸ **Check for Updates…**. EXPECT "A new version of Variorum is
       available! Variorum 0.0.2 is now available—you have 0.0.1." **CAPTURE W7.**
     - **Install.** Press **Install Update**. EXPECT a download, then "Ready to Install", then
       **Install and Relaunch**. **CAPTURE W8.**
     - **The XPC installer road.** Variorum quits. Sparkle's installer, launched over XPC OUTSIDE
       the sandbox, replaces `~/Applications/Variorum.app`, and Variorum relaunches.
     *[removed for publication]*
       folder. If any dialog appears, capture it and note it.

   - **W-9. [HER] AFTER THE RELAUNCH:**
     - Variorum ▸ About reads **0.0.2 (4830)**. **CAPTURE W9.**
     - The library from W-5 is still there: the store survived the update. **CAPTURE W10.**
     *[removed for publication]*
       ```sh
       *[removed for publication]*
       *[removed for publication]*
       *[removed for publication]*
       ```
       Expect `0.0.2`, **accepted / Notarized Developer ID**, and `seal valid`.
     *[removed for publication]*
       session.

   - **W-10. [O] Back in her session:**
     - **(a) The server.**
       ```sh
       kill "$(cat <home>/dev/variorum/App/Variorum/DerivedData/13r-u2/walk-server.pid)"; cat <home>/dev/variorum/App/Variorum/DerivedData/13r-u2/walk-server.log
       ```
       Expect `GET /appcast.xml` and `GET /Variorum-0.0.2.dmg` 200 lines: the update's download,
       seen from the server's side.
     - **(b) The captures.** Copy `/Users/Shared/VariorumWalk/captures/*` into
       *[removed for publication]*
     - **(c) The logs** (optional, read-only; `log` is a zsh builtin, so call `/usr/bin/log`):
       `/usr/bin/log show --start "<W-0(f)'s START>" --predicate 'subsystem == "org.sparkle-project.Sparkle" OR process == "Installer" OR process == "Autoupdate" OR process == "Updater"' --style compact | tail -80`.
     - **(d) [HER]** Reopen `/Applications/Variorum.app` as always. Expect it undisturbed: the walk
       *[removed for publication]*
     - **(e) THE VERDICT, into this record.** **PASS** = all of the following:
       - W1: the quarantined DMG opened clean;
       - W-4: `spctl` accepted the installed app;
       - W2: the notarized first-launch question appeared, not a block;
       - W3: the first run on a fresh container store;
       - W6: consent was ASKED, with no profile option;
       - W7–W8: 0.0.2 was found and the XPC install landed;
       *[removed for publication]*
         valid.

   - **STOP RULES, any step:**
     - a Gatekeeper BLOCK;
     - a Sparkle "An error occurred…" alert (capture it, ⌘Q, log out, report);
     - the installer failing, or a relaunch that still reads 0.0.1 (capture About);
     - anything touching HER account's Variorum.

     **The walk never touches `/Applications`, her real store, or the public feed.**
   - **Left for later, NOT cleaned now:**
     *[removed for publication]*
     - **`/Users/Shared/VariorumWalk/`, the walk builds and the walk feed** go at the closeout's
       debris sweep. The builds sit under `.noindex` with zero live LaunchServices registrations;
       the feed sits under DerivedData, gitignored.
   *[removed for publication]*
     *[removed for publication]*
     is removed.

**THE U2 WALK VERDICT (the orchestrator, 2026-10-04, the walk sitting — W-10(e)): PASS, every
*[removed for publication]*
*[removed for publication]*
`notes/plans/13r-screens/u2-walk/`.
- **W-0 (her session, the orchestrator):** zero instances; both walk DMGs stapler-validated +
  Gatekeeper ACCEPTED with their recorded sha256s; **W-0(c) the walk appcast — `VERDICT: PASS`,
  7/7, the `edSignature` VERIFYING under the baked `SUPublicEDKey`: the first end-to-end proof
  that her login Keychain's private key is the shipped public key's twin** (no Keychain prompt
  surfaced on this run); the feed served detached on `localhost:8765`; walk A staged
  quarantined in `/Users/Shared/VariorumWalk/`.
*[removed for publication]*
  feed across the user switch (`1` item) and the quarantine read back byte-identical.
- **W-4 `spctl` accepted the installed app:** ✔ — `~/Applications/Variorum.app: accepted /
  *[removed for publication]*
  quarantine inherited (0183 after her approval).
- **W2 the notarized first-open question, not a block:** ✔ — the OS's one-time "downloaded from
  the Internet" question, on the DMG copy and again on the `~/Applications` copy (each newly
  quarantined copy asks once).
*[removed for publication]*
- **W6 consent ASKED, no profile option:** ✔ — and her RULING R-13r-11 changes its timing in U3.
- **W7–W8 0.0.2 found and the XPC install landed:** ✔ — "Variorum 0.0.2 is now available—you
  have 0.0.1" (captured 13:31:03); the server log shows the app's own `GET /appcast.xml`
  (13:31:02) and `GET /Variorum-0.0.2.dmg` (13:31:12); no password asked.
- **W9–W10 relaunched as 0.0.2 with the library intact, `spctl` accepted, seal valid:** ✔ —
  *[removed for publication]*
  *[removed for publication]*
  Developer ID`, `seal valid`.
- **W-10(d) her return leg:** ✔ — her words: *"my variorum opened just fine."* The walk touched
  *[removed for publication]*
  public feed. The server is stopped.
- **Findings the walk produced (all recorded in the LIVE STATUS's walk-sitting bullet):** the
  art-less DMG's Applications link went unseen and she launched from the mounted DMG →
  **R-13r-10** (the self-explaining DMG window, U3); the consent prompt greeting an early launch
  *[removed for publication]*
  `/Applications` → U3's walk launches by explicit path; the first "Update Error" was the
  unwritten feed override (the baked public feed correctly 404s pre-release) — not a defect;
  her 13s onboarding note (the backups popup on open).
*[removed for publication]*
  localhost override), `/Users/Shared/VariorumWalk/`, the walk builds and the walk feed — swept
  at the closeout.

---

## U3-A RECORD (the implementer's LIVE STATUS — Opus, 2026-10-04; DONE(hash) / IN-PROGRESS / PENDING)

**NOT DONE BY THIS SUB-PHASE (stated first, per the contract; FINAL at the stop):**
- **THE DMG WINDOW'S LAYOUT NEVER RAN.** Scripting Finder is DENIED for this Mac's terminal host
  (Ghostty, status −1743, measured). `make-dmg.sh` and `release.sh` therefore REFUSE at preflight
  until **HER HANDS: System Settings ▸ Privacy & Security ▸ Automation ▸ Ghostty ▸ Finder → ON**.
  The window is unverified on screen; its first proof is the no-notarization dry run in piece 5
  (it reads the layout back and prints PASS/FAIL), then the walk's arm (a). Everything around it
  (the drawn background, the RW→UDZO road's refusal, the read-back parser on real Finder data, the
  notes embedding with the real 2.10.0 tool) was exercised.
- **Release-only faces were not walked here (P-2 makes them absent in Debug, by design):** the
  update ask (Sparkle's own window from day 3), Settings ▸ General's "Check for updates
  automatically", and the calm sync face's Check for Updates… door. They are pinned; their USE is
  the U3 walk's arms (b) and (e). The calm sync face cannot be reached on any build here (the dev
  *[removed for publication]*
- **The field guide's new passage was not seen on screen:** Help ▸ Restore Tutorial… is a
  wholesale replace of the dev store's guide, which this session declined to do to the dev store;
  the passage is pinned headless (`TutorialWalkTests`), and the closeout's real-store re-seed is
  where it is first seen.
- **The U3 walk sheet is not written** (staged after U3-B, per the plan); this record hands it the
  day-counter recipe (piece 6) and the DMG dry run (piece 5). Nothing was published (the public
  appcast stays 404); `/Applications` and the real store were never touched; zero
  `Sources/VariorumCore/Sync/`, zero schema, zero mobile-target files (the mobile target BUILDS).
- **A PRE-EXISTING red, not this unit's, routed not fixed:** `DataSafetyRunbookTests
  .theShippedRunbookAndTheRepoCopyAreOneDocument` fails at the U3-A base too —
  `notes/DataSafetyRunbook.md` line 291 still says "on your shelf" while `DataSafetyCopy.runbook`
  has said "on your Bookcase" since 13i-d U6 (`827da96c`); confirmed at `138ac723` before any U3-A
  line. The fix is a one-line repo-doc sync (copy the rendered text the test writes over the repo
  file) — the orchestrator's to place (a 19 entry or the closeout).
- U3-B (MetricKit, Diagnostics, Help ▸ Send Feedback…) — not this session's. The full Mac and core
  suites were not run (the brief names the touched families; the ladder's "suite green" is the
  phase's).

**Session start (2026-10-04 ~19:58Z):** toolchain re-read — macOS 27.0 (26A428) · Xcode 27.0
(27A266a) · `xcode-select -p` = `/Applications/Xcode.app/Contents/Developer` (the pinned pair).
Zero instances (`pgrep -fl 'Variorum.app/Contents/MacOS'`: no match). HEAD `138ac723` = origin,
tree clean, commit count 4878. Brief read in full in this session: the plan's KICKOFF, SITTING
RECORD, the U3 section with every amendment (R-13r-10…14, THE CALM-ASKS CADENCE, the walk arms,
the hazards, SIZING), ENVIRONMENT TRAPS, THE LADDER, the LIVE STATUS from THE RESUME RECORD down,
the U2 RECORD (pieces 4 and 5 especially); `notes/SessionResiliencyProtocol.md`. Sparkle facts
re-read from the 2.10.0 checkout (`SPUUpdater.m startUpdateCycle`, `SPUUpdaterDelegate.h`,
`generate_appcast/ArchiveItem.swift`) before relying on them — recorded per piece.

**Pieces (the SIZING bullet's U3-A list; order chosen so each lands whole):**
1. R-13r-6 — the stamping build phase + MARKETING_VERSION 0.9.0 — **DONE (this commit)**.
   - `App/Variorum/StampBuildNumber.sh` (new): `git rev-list --count HEAD` → `PlistBuddy Set
     :CFBundleVersion` on `${TARGET_BUILD_DIR}/${INFOPLIST_PATH}`; refuses loudly (fails the build)
     on no git, a shallow/missing checkout, or a non-positive count — never guesses.
   - `project.pbxproj`, the Mac target ONLY: a `PBXShellScriptBuildPhase` "Stamp Build Number"
     (`E1B5A0102F0000000000AA10`) as the LAST phase after Resources, `alwaysOutOfDate = 1`, input =
     the processed Info.plist (orders it after its producer); `ENABLE_USER_SCRIPT_SANDBOXING = NO`
     on the Mac target's Debug + Release (git must read `.git`, which no input list can name — the
     project-level YES is untouched for every other target); `MARKETING_VERSION` 1.0 → **0.9.0** on
     the Mac target's two configurations (the mobile target's own settings untouched — not this
     phase's). No build configuration added.
   - **Verified (fresh `-derivedDataPath DerivedData/13r-u3a/p1-debug`, Debug):** BUILD SUCCEEDED;
     the log orders `ProcessInfoPlistFile …/Variorum.app/Contents/Info.plist` (line 3700) →
     `PhaseScriptExecution Stamp\ Build\ Number` (5670, "CFBundleVersion = 4879") → `CodeSign
     …/Variorum.app` (5703); the bundle reads `CFBundleVersion 4879` = `git rev-list --count HEAD`
     at that HEAD, `CFBundleShortVersionString 0.9.0`; `codesign --verify --deep --strict` → valid
     (the stamp is inside the seal). No stamp-phase warning in the log.
   - The release pipeline keeps BOTH roads (U2's interface note allowed either): it still passes
     `CURRENT_PROJECT_VERSION` = the count as an override (the xcarchive's own metadata reads the
     setting) and `verify-export.sh --expect-build` still asserts the shipped bundle — the phase
     writes the same number from the same clean HEAD.
   - Pin: `VariorumTests/VersionSchemeTests.swift` (3 tests — the stamped count ≥ 4879, the 0.9.x
     line, the phase's shape in the project file). Red-on-old by construction (old bundle: `1` /
     `1.0`, no phase). Suite run: PENDING (the finals).
2. R-13r-13 — the out-of-date sync refusal's calm face — **DONE (this commit)**. ZERO `Sync/` lines
   (the engine and its sentence untouched; `git diff --stat` names no `Sources/` path).
   - `Shared/SyncStatusViews.swift`: `SyncRowFace.Kind.appOutOfDate` + `Door.Act.checkForUpdates`;
     `face(…, canCheckForUpdates: Bool = false)` (defaulted — every existing pin reads unchanged);
     the classifier `SyncRowFace.isAppBehindServerError` on the `isKeysLockedError` exactness rule
     — it reads the two markers out of the text, then demands the WHOLE string equal the engine's
     own `String(describing: SyncError.schemaLockstepMismatch(client:server:))` (exactly what
     `SyncScheduler` writes into `lastError`), and answers true only when server > client. The
     app-ahead direction falls through to the generic face, as ruled. Calm words: the line "Sync
     paused — this version of Variorum needs an update" in the QUIET caption (the notEntitled
     register, never the error red), and under it her letter: "This version of Variorum is older
     than your account's sync format. Update Variorum to continue syncing — nothing is lost while
     sync is paused." The engine's own sentence rides the hover, as every paused state's does.
   - THE DOOR (P-2): an environment value `checkForUpdatesDoor` (nil by default); the Mac's
     `VariorumApp` injects `UpdateChannel.syncRowDoor`, which is nil unless the channel is LIVE —
     so a Debug build's row and the phone's row say the sentence alone, and a Release row offers
     Check for Updates… (the menu door's own act and words; a Mac pin holds the labels equal).
   - **MOBILE-VISIBLE, flagged for the closeout's parity line:** the face is `Shared/`, so the
     phone's Settings sync row gains the calm sentence (no door — its updates are the App Store's)
     in place of the generic error for this one refusal. No mobile file was touched.
   - Pins: `VariorumTests/SyncOutOfDateFaceTests.swift` (6 — server-ahead → calm face + the door;
     no updater → calm face, no door; app-ahead → the generic face with Retry/Account; the
     classifier's exactness — prefix, suffix, equal pair, another refusal, a bare marker pair;
     the words + label equality with the menu's; the inert channel hands out no door).
     **Run green with piece 1's suite and `SyncStalledRowTests`: `Test run with 11 tests in 3
     suites passed`, no `skipped:` line** (log `App/Variorum/DerivedData/13r-u3a/p2-test.log`).
     Red-on-old: the mutation run is in the finals (PENDING).
3. R-13r-14 — the field guide's backups passage — **DONE (this commit)**.
   - **THE PLACEMENT, proposed and built (mine to propose, per the brief): two paragraphs at the
     END of the existing lesson "export — it's all yours" (chapter "the library of things"), not
     a lesson of its own.** Why: (a) the lesson's promise is "your work is always yours to take
     out" — export is the copy you TAKE, a backup the copy Variorum KEEPS, the same promise from
     the other side, so the passage reads as the lesson's natural second half; (b) the privacy
     chapter was the other candidate, but its two lessons are copy §7 VERBATIM from constants
     the PHONE's seeder renders too — adding the second-folder door there would teach the phone a
     door it does not have (the picked-folder road is Mac-only) and re-open her "SHORT chapter"
     ruling; (c) a lesson of its own would change the plan's lesson list (the walk contract's
     shape) for two paragraphs. The Mac seeder only — the phone is untouched.
   - The words (every name the surface's own constant, P-6): where backups live on their own
     ("Once a day while Variorum is open, it copies your whole library into a backups folder
     right beside the library, on this Mac"), that they survive a mistake but not losing the
     Mac, then the door — "Settings ▸ `SettingsPane.dataSafety.title`, under
     “`DataSafetyCopy.secondFolderSection`” — its `CapabilityRegistry .chooseBackupFolder` verb
     button", iCloud Drive named among the choices — and R-13r-12's offer in its own words
     ("…a quiet note at the bottom of the window: “`ProtectionCopy.iCloudOfferTitle`”").
   - `DataSafetyCopy.secondFolderSection` ("A second folder") is new, and the Data Safety pane
     now renders its section title FROM it, so the lesson and the pane cannot drift.
   - Pin: `TutorialWalkTests.theExportLessonTeachesWhereBackupsLiveAndTheSecondFolderDoor`
     (compiled in piece 2's test build; the suite runs in the finals — PENDING). The lesson PLAN
     (chapter + lesson titles) is unchanged, so `theSeededBookMatchesTheLessonPlanExactly` and
     the export-to-one-document pins hold as they are.
   - **THE CLOSEOUT'S RE-SEED DUTY FIRES** (the standing rule): this lesson-content edit stales
     the REAL store's seeded field guide; the orchestrator re-seeds it via the product door
     (Help ▸ Restore Tutorial…) behind the A1 rail at the refresh window. This session never
     touches the real store.
4. The ONE release-notes source → What's New — **DONE (this commit)**.
   - **THE SOURCE:** one Markdown file per marketing version,
     `App/Variorum/Variorum/Features/WhatsNew/ReleaseNotes-<version>.md`, bundled by the
     synchronized group (measured: `Contents/Resources/ReleaseNotes-0.9.0.md` in the Debug
     bundle). A deliberately small grammar both renderers agree on (`#`/`##`/`###` headings,
     `- `/`* ` bullets, joined paragraphs, inline bold/italic/code/links) — `ReleaseNotes.swift`.
     The appcast half (release.sh renders the same file beside the DMG) is piece 5.
   - **0.9.0's notes are a FUNCTIONAL DRAFT for HER to rewrite before the first release** (13s
     owns the voice): thanks, what this build is (library on this Mac, encrypted on disk; sync
     optional; updates — the ask after a few days, Check for Updates… any time), where to start
     (Help ▸ Open the Tutorial; Settings ▸ Data Safety's second folder), and the support address.
     It promises no unbuilt door (Help ▸ Send Feedback… is U3-B's, so the notes name the address).
   - **THE LEDGER (`WhatsNew.swift`), built to the architect's reading:** a LOCAL preference of
     this app (`variorum.whatsNew.lastVersion` — never synced; a version is a fact of the
     installation), decided ONCE per process at launch on the MARKETING version (never the build
     number, which moves every commit): no record → record silently, show nothing (a fresh
     install, and every existing install's first stamped build — the calm direction, her daily
     drive included); same → nothing; a CHANGED recorded version → due. The first window claims
     the show once per process; the version is settled only when the sheet is actually on screen
     (`onAppear`), so a sheet that never appeared stays due next launch. The app delegate owns
     the one ledger (the `updates`/`appearance` precedent) and hands it to `RootView`.
   - **THE SHEET:** on the main window, in the voice (P-8: the window's `ThemeStore` tokens via
     the environment, `VoicedButtonStyle` primary "Continue" on ⏎, the title line-limited), the
     notes scrollable and selectable; a build with no notes for its version (a walk build) says
     so plainly ("Variorum is now version X. This build doesn't carry notes for it.").
   - **Help ▸ What's New** — a request the window adopts (`ShellRouter.whatsNewRequested`, the
     `quickNoteRequested` shape), on the creation router so it lands in a full window, greyed when
     none exists (P-2). **UNDECLARED in the capability registry on the "Open the Tutorial"
     precedent one line above it — flagged for the ladder as a P-1 reading, not a product call.**
   - Pins: `VariorumTests/WhatsNewTests.swift` (7 — fresh = silent + recorded; THE SHOW-ONCE across
     a simulated run of launches 0.9.0 → 0.9.0 → 0.9.1 → 0.9.1 → 0.9.1 → 0.9.2 → 0.9.2, shown
     exactly at the two changes; one claim per process; a never-shown claim stays due; the
     RUNNING version carries its notes in the bundle (a bump without notes is red); the grammar;
     the Help door's source line). **Run: `Test run with 7 tests in 1 suite passed`, no
     `skipped:`** (log `13r-u3a/p4-test.log`).
5. `release.sh`: the notes into the appcast + R-13r-10's self-explaining DMG window — **DONE (this
   commit) — the Finder leg UNVERIFIED BY THIS SESSION: it needs a permission that is HER HANDS.**
   - **THE NOTES ROAD:** `release.sh` preflight finds `…/WhatsNew/ReleaseNotes-<version>.md` —
     a RELEASE refuses without it; a walk build may lack it (said, and the app shows its honest
     no-notes line). `make-appcast.sh --notes MD` (REQUIRED in release mode) copies it into the
     feed as `Variorum-<version>.md` beside its DMG — an existing copy with different bytes is
     refused (immutability's spirit) — and `generate_appcast` now runs with
     `--embed-release-notes`, so the item carries `<description sparkle:format="markdown">`
     (Sparkle 2.10.0 renders Markdown natively — `SUUpdateAlert` → `SUTextViewReleaseNotesView
     prefersMarkdown:YES`, read from the checkout). The notes STAY in the feed: read from
     `generate_appcast`'s source (`FeedXML.swift`), every run re-embeds each item from the file
     beside its DMG and REMOVES the description of an item whose file is gone. `verify-appcast
     .swift` gains an optional 7th argument and two checks: the description is the notes
     verbatim, and its format is markdown.
   - **PROVEN with the real 2.10.0 tool, never her Keychain:** a scratch feed holding a DMG of the
     piece-1 Debug app + the 0.9.0 notes, `generate_appcast --ed-key-file <a THROWAWAY CryptoKit
     key> --embed-release-notes` → "Wrote 1 new update", the item's `<description
     sparkle:format="markdown">` = the notes' CDATA; `verify-appcast` with the notes → both notes
     checks PASS; with a different notes file → "not the release notes" FAIL; with none → "no
     release notes expected" PASS. (Its edSignature check FAILED there by design: generate_appcast
     refuses to sign an app whose baked `SUPublicEDKey` is not the signing key's twin — the
     throwaway key never is. U2's walk W-0(c) proved the real signing road.) The extracted
     `.debug` app copy in `generate_appcast`'s cache was unregistered and its entry removed.
   - **THE DMG WINDOW (R-13r-10) — `Tools/Release/make-dmg.sh`, her ruled road, no new
     dependency:** stage the app + the `/Applications` link + `.background/background.tiff` →
     `hdiutil create` a READ-WRITE image (UDRW, HFS+, "Variorum") → attach at `/Volumes/Variorum`
     (refused if a "Variorum" volume is already mounted — Finder must address exactly one) →
     AppleScript tells Finder: icon view, toolbar + status bar hidden (the sidebar goes with the
     toolbar), bounds 660×400 content, not arranged, 128-pt icons, the background picture, the app
     at (165, 190) and Applications at (495, 190) → Finder writes the `.DS_Store` INTO the RW
     image → the layout is READ BACK from that `.DS_Store` (`--verify-layout`) → detach → `hdiutil
     convert` UDZO, `Variorum-<version>.dmg`. `release.sh` step 4 calls it; signing/notarizing is
     unchanged and comes after (the layout is inside the seal and the ticket); step 7 reads the
     layout back again from the SHIPPED, stapled DMG.
   - **The arrow:** `Tools/Release/dmg-background.swift` (AppKit drawing, compiled with `xcrun
     swiftc` like `verify-appcast.swift`) draws a plain mid-grey arrow across the gap between the
     icons and "Drag Variorum to Applications" under it on a near-white room, 1× and 2×
     (`tiffutil -cathidpicheck` → one HiDPI TIFF). Seen (the 2× PNG read back): upright, centred,
     between the icon positions. Functional only — 13s's art replaces the file.
   - **The layout verifier is proven on real Finder data:** its record parser read `bwsp`/`icvp`
     plists and `Iloc` blobs out of four Finder-written `.DS_Store` files in her home (read only:
     e.g. `WindowBounds '{{404, 486}, {920, 436}}'`, `backgroundType 0`), and it FAILS a DMG with
     no layout ("no .DS_Store … the window was never laid out", exit 1).
   - **THE PERMISSION — MEASURED, HER HANDS:** scripting Finder needs the user's Automation
     consent for the terminal app running the pipeline. `finder-automation-check.swift` asks the
     system WITHOUT prompting (`AEDeterminePermissionToAutomateTarget`, askUserIfNeeded false).
     **On this Mac today the host (Ghostty) is DENIED for Finder (status −1743; for comparison
     Terminal.app reads −1744, never asked).** So `make-dmg.sh --check` refuses, and `release.sh`
     refuses at PREFLIGHT (before the archive and an hour of notarization), naming the toggle:
     **System Settings ▸ Privacy & Security ▸ Automation ▸ Ghostty ▸ Finder → ON.** Measured
     here: `make-dmg.sh --app <Debug app>` → REFUSED exit 3 before any hdiutil. **Consequence for
     the orchestrator: no U3 walk DMG can be built until she flips that toggle; then the first
     run is the window's verification** — a one-line dry run needs no notarization:
     `Tools/Release/make-dmg.sh --app App/Variorum/DerivedData/13r-u3a/p1-debug/Build/Products/Debug/Variorum.app --version 0.0.99 --out <scratch dir>`
     (its read-back prints PASS/FAIL per setting; then `open` the DMG and capture the window).
   - **Facts for the ladder:** on macOS 27.0 `hdiutil create/attach/detach` print a DEPRECATION
     warning ("use diskutil image …") but work — her ruling names hdiutil, and U2's pipeline
     already used it; recorded, not acted on. **The dark-mode question is open for the walk's arm
     (a):** Finder draws icon labels over the near-white background; whether it keeps them dark
     under a dark system appearance could not be measured without Finder access — capture arm (a)
     in both appearances if she can.
6. THE CALM-ASKS CADENCE — **DONE (this commit)**, built as written (her kickoff ratified it).
   - **THE ONE SCHEDULER — `App/Variorum/Variorum/Features/CalmAsks/CalmAsks.swift` (Mac only,
     under `Features/`, never `Shared/`):** the pure `CalmAskRules` (eligibility, the one ask per
     day in rank order, the calm moment, the day-of-use count) + `CalmAskScheduler` (the app
     delegate's one instance). Days of use are counted in LOCAL preferences
     (`variorum.calmAsks.daysOfUse` / `.lastUseDay`, never synced) at launch AND at every
     `applicationDidBecomeActive` — so an app left open across midnight counts the new day when it
     next becomes active. The shared rules: nothing on day 1; never before 2 minutes open, 20 s
     since the last keystroke (a LOCAL `keyDown` monitor — this app's keystrokes only, the event
     returned untouched), never while a sheet (ceremonies and What's New are sheets), a modal, a
     menu or a drag is open (`RunLoop.main.currentMode == .eventTracking`) or while the app is not
     frontmost; ONE ask per day and the two never share one (`lastAskDay`); a quiet evaluation
     every 15 s, O(registered asks), the store read only when an ask is otherwise due. Asks
     REGISTER (id, rank, first day, max shows, return gap, `wantsAsking`, `present`), so a later
     ask (13s onboarding) joins the same rules.
   - **THE UPDATE ASK (R-13r-11) — `UpdateChannel`:** the updater delegate `PermissionDeferral`
     implements Sparkle's `updaterShouldPromptForPermissionToCheckForUpdates:` (its Swift name is
     `updaterShouldPromptForPermissionToCheck(forUpdates:)`; the selector is pinned explicitly with
     `@objc(…)`) and answers NO — read from the 2.10.0 source FIRST: the delegate is consulted only
     while `SUEnableAutomaticChecks` is absent from defaults AND Info.plist, and Sparkle prompts on
     the second launch only when the delegate does NOT implement it; with NO the cycle schedules
     nothing (`automaticallyChecksForUpdates` reads NO until answered), so no automatic check runs
     before consent; Check for Updates… works from day one (unchanged). From the 3rd day of use, at
     a calm moment, `askPermission()` shows SPARKLE'S OWN permission window through its standard
     user driver (`SPUUserDriver show(_:reply:)` — the public protocol) and applies the answer
     exactly as Sparkle's `updatePermissionRequestFinishedWithResponse:` does; the menu door greys
     while that window is up (Sparkle does not know it is showing). The answer is Sparkle's own
     record — `SUEnableAutomaticChecks` in the defaults (`permissionAnswered`); registered ONLY
     where the channel is live (P-2: never in a Debug build). Rank 0, re-asks a later day only if
     the window was closed unanswered (PROVISIONAL (c) in #180).
   - **THE BACKUP-FOLDER ASK (R-13r-12):** the first-backup-run trigger is RETIRED —
     `ICloudDriveOfferModel.consider(after:)` and RootView's `services.backup?.onRun` hook are gone;
     the model gains `stillWantsAsking()` (the existing mark + a picked folder marks silently, as
     before) and `openSheet()`. RootView registers the ask (rank 1, from the 5th day, at most twice,
     7 days apart — "ignored, it returns ONCE more after 7 further days of use, then never") once
     its services exist, and takes back only its own registration when it closes. The ask is an
     OFFER toast on the status seam — "Keep a copy of your backups in iCloud Drive?" (the sheet's
     own title) with **Set Up…** (opens today's three-door sheet) and **Not Now** (the existing
     mark): `StatusCenter.Item` gains a defaulted `secondary` door and `offer(_:action:secondary:)`;
     `StatusToast` renders it quiet, before the act; either door dismisses as it acts. The toast
     keeps the app's ONE 6-s clock; a timeout or ✕ counts as ignored. **"Writing of the user's
     own"** = `OwnWriting.exists` — a live note with words on its page wearing none of the seeded
     tags (the seeders' own constants: `TutorialSeeder.tagName`, every `SampleLibrarySeeder.Book`
     tag, `#classics`) and not the seeded quick note (its reserved title); one EXISTS read,
     latched once true, a "no" re-read at most every 5 minutes (`OwnWritingProbe`).
   - **Settings ▸ General — "Check for updates automatically"** (a new Updates section, rendered
     ONLY where the channel is live — P-2): the Toggle IS Sparkle's own
     `automaticallyChecksForUpdates` (KVO-mirrored), so touching it writes the answer and the ask
     retires for good; while unanswered the caption adds "You haven't chosen yet — Variorum asks
     once, after a few days of use, or you can decide here." The catalog gains the row (`updates`,
     General) so Settings search finds it. (In a Debug build the row is not rendered — the
     `appearance` row's precedent for a catalogued-but-conditional control.)
   - **THE ONE QUESTIONS ENTRY: `notes/QUESTIONS.md` #180** — the five numbers + six readings
     (a)–(f) the cadence is silent on + the 0.9.0 notes draft. **THE WALK'S DAY-COUNTER RECIPE
     (container-path `defaults write`, walk build only, app QUIT first):** to make the next launch
     day N, write `variorum.calmAsks.daysOfUse` = N−1 and `variorum.calmAsks.lastUseDay` = a past
     *[removed for publication]*
     and `… variorum.calmAsks.lastUseDay -string 2000-01-01` → the next launch is day 3 (the
     update ask after 2 minutes); `-int 4` → day 5 (the backup offer, once a note of hers holds
     words, and not on a day an ask already appeared — `variorum.calmAsks.lastAskDay` records it).
   - Pins: `VariorumTests/CalmAsksTests.swift` (15 — the numbers; nothing before its day, one per
     day, rank order; the backup ask's once-more-after-7-then-never; the calm moment; the day count;
     A SIMULATED RUN of 30 days of use through the real scheduler (shown exactly: update on day 3,
     backup on day 5 once she has writing, again on day 12, never after); never at launch / while
     typing / over a sheet; the update ask still open on day 5 takes it and the backup ask waits a
     day; midnight counted on becoming active; window-scoped unregistration; the deferral answers
     Sparkle's own selector with NO; the inert channel never asks and reads Sparkle's own key; the
     Settings row; the two-door offer with the sheet's own words; OwnWriting over an in-memory store
     — the seeded field guide is not hers, a blank note is not writing, a seeded-tag note is not, her
     note with words is). `ICloudDriveOfferTests` moved to the new opener (`openSheet()`), every door
     assertion unchanged, its first pin now holding the retirement (RootView carries no `onRun`).
     **Runs:** piece 6's eight suites `Test run with 78 tests in 8 suites` — every suite but
     CalmAsks green; CalmAsks' 3 issues were the TEST's own (a "past midnight" hour that was not, and
     a missing seeded RNG dependency), fixed → **`Test run with 15 tests in 1 suite passed`** (logs
     `13r-u3a/p6-test.log`, `p6-test2.log`). No `skipped:` lines.
7. Finals — **DONE (this commit)**.
   - **MUTATION RUN IN FLIGHT (named before it starts, per the protocol's addendum 2; the
     committed tree `6151f47a` is the pre-revert copy):** three production files are mutated
     together — `Shared/SyncStatusViews.swift` (the classifier answers false), `Features/WhatsNew/
     WhatsNew.swift` (a fresh install is due), `Features/CalmAsks/CalmAsks.swift` (`next` drops
     the one-per-day guard) — and restored with `git checkout --` on exactly those three paths.
     If a session dies mid-run, `git diff` against `6151f47a` shows what is mutated; restore it.
     **THE MUTATION RUN — DONE, RESTORED (`git checkout --` on the three paths; tree clean but the
     strengthened pin below):** with the three mutants in, `Test run with 28 tests in 3 suites
     failed … with 10 issues` — the sync face: 5 issues across the server-ahead, no-updater and
     exactness pins (the pre-fix face is the generic one); What's New: 4 issues across the fresh-
     install and show-once pins (a greeted fresh install); the cadence: the pure one-per-day pin.
     **The run found one HOLLOW SPOT in my own pins and it was strengthened, not fixed in code:**
     the scheduler's own `lastAskDay` guard (mutated with the rule's) was caught by no scheduler
     pin, because the update ask's one-day re-ask gap masks a same-day second evaluation in every
     scripted day. `theUpdateAskStillOpenOnDayFiveTakesItAndTheBackupAskWaits` now evaluates twice
     on the day BOTH asks are due — red under the mutant (2 issues, `13r-u3a/mutants3.log`), green
     restored. **Restored run: `Test run with 28 tests in 3 suites passed`** (`restored.log`).
     Red-on-old by construction, not mutated: `VersionSchemeTests` (the pre-fix bundle reads `1` /
     `1.0` — her own About screenshot of the old daily drive, "1.0 (1)"); the iCloud retirement pin
     (the pre-fix `RootView.swift` carries `services.backup?.onRun = { record in
     offer.consider(after: record) }` at line 248 — `git show 138ac723:…/RootView.swift`).
   - **DEV-STORE WALK IN FLIGHT (Debug build, `io.lduarte.Variorum.debug`, the fenced dev store):**
     the dev domain's prefs were EXPORTED first to the gitignored
     `App/Variorum/DerivedData/13r-u3a/devprefs-prewalk/io.lduarte.Variorum.debug.plist`; for the
     backup-offer capture the walk DELETES `variorum.backup.secondDestination` (a dev bookmark) and
     the dev offer mark, and sets the day counter. **Restore at the walk's end (app quit):
     `defaults import ~/Library/Containers/io.lduarte.Variorum.debug/Data/Library/Preferences/io.lduarte.Variorum.debug <that export>`.**
     The voice was switched to Study for captures (a dev-store synced setting) — switched back to
     Terminal at the end.
     **RESTORED:** the dev prefs re-imported and the walk's three extra keys deleted — the domain's
     export now equals the pre-walk export (diffed, equal); the voice set back to Terminal.
   - **THE DEV-STORE WALK (Debug build `13r-u3a/p1-debug`, `cliclick` + `Tools/WalkKit`, every
     step behind `guard.sh`; HER app absent throughout, idle > 40 min at the start). Captures in the
     gitignored `notes/plans/13r-screens/u3a/`:**
     - `a1/w0.png` — **What's New at LAUNCH after a version change** (the ledger set to a recorded
       0.8.9; the build is 0.9.0): the sheet over the Bookcase in the TERMINAL voice, the 0.9.0
       notes rendered (headings, bullets, bold, the support link), "Continue" on ⏎. The record
       read 0.9.0 immediately after (settled on appearance).
     - `a2/` — after Continue: the main window alone. `a3/` — **the NEXT launch: no sheet** (the
       show-once, walked).
     - `a4/` — **Help ▸ What's New** on demand (the menu listed: Shortcuts & Dictionary · Open the
       Tutorial · What's New · Restore…), Terminal.
     - `a5-study/w0.png` — Help ▸ What's New in the **STUDY** voice (serif, the voice's own room).
     - `s1/w0.png` — Settings ▸ General in a Debug build: **no Updates section** (P-2 — the channel
       is inert in Debug; the row is Release-only).
     - `b1/w0.png` — **THE BACKUP OFFER on day 5** (the day counter set to 4 + a past day; the dev
       store's second-folder bookmark and offer mark removed for the walk): it fired at the first
       15-s tick past 2 minutes (launch ~14:54:48, shown 14:56:55, nothing typed), as the bottom
       toast "Keep a copy of your backups in iCloud Drive?" · Not Now · Set Up… · ✕ (Study voice);
       the prefs then read day 5, `backupFolder.timesShown 1`, `lastAskDay 5`.
     - `b2/w0.png` — **Set Up… → the three-door sheet** (re-armed once to click it inside the 6-s
       window); Escape answered it as Not Now and the dev mark read 1 again.
   - **SUITES (zero-instance windows):**
     - the 22 touched/neighbouring suites (registry walk, shell chrome, Open strip menu, chord
       legibility, update channel, entitlements, version scheme, What's New, calm asks, the two sync
       faces + EncryptionFlow's face pins, the iCloud offer, Settings shape, confirmations, status
       vocabulary, Data Safety's runbook, no-literal-colour, the two debug-oracle window suites,
       shell confirm, PostureSwitch): **`Test run with 209 tests in 22 suites` — 1 issue, the
       PRE-EXISTING runbook drift above, nothing else**; the `skipped:` lines are exactly the 7
       `DebugOracleSingletonWindowTests` tests + their suite, opt-in-disabled by design
       (`VARIORUM_ORACLE_SINGLETON_WINDOWS`) (log `13r-u3a/close-suites.log`).
     - every suite in the tutorial, command-routing (incl. `StatusCenterTests`), shell-landing,
       windows and note-box files (34 suites): **`Test run with 166 tests in 34 suites passed`**,
       no `skipped:` — the new `theExportLessonTeachesWhereBackupsLiveAndTheSecondFolderDoor`
       among them (log `close-suites2.log`).
     - **The mobile target BUILDS** (`Shared/SyncStatusViews.swift` changed; fresh
       `-derivedDataPath 13r-u3a/mobile.noindex`, `generic/platform=iOS Simulator` → BUILD
       SUCCEEDED, `mobile-build.log`).
     - **A CLEAN Debug build** (fresh `13r-u3a/clean-debug`) → BUILD SUCCEEDED, stamped by the new
       phase; **its warning set is IDENTICAL to U2's p4 clean build** (22 unique file+message pairs
       on each side under one normalisation, `diff` empty — U2's "28" counted differently).
   - **For the ladder (flagged, not decided):** the two UNDECLARED menu doors on their precedents
     (Help ▸ What's New beside "Open the Tutorial"; U2's Check for Updates…); `StatusCenter.Item`'s
     new `secondary` door (the one-door offer shape widened for this ask); the deferral's
     `@objc(updaterShouldPromptForPermissionToCheckForUpdates:)` pin (Sparkle calls it by selector);
     `askPermission()` driving Sparkle's standard user driver directly (the public `SPUUserDriver`
     road — Sparkle's own `_showingPermissionRequest` stays NO, so the channel greys its own menu
     door while the window is up); `ENABLE_USER_SCRIPT_SANDBOXING = NO` on the Mac target only;
     the `hdiutil` deprecation warning on macOS 27; the Finder-automation dependency of the ruled
     DMG road.

---

## U3-B RECORD (the implementer's LIVE STATUS — Opus, 2026-10-04; DONE(hash) / IN-PROGRESS / PENDING)

**NOT DONE BY THIS SUB-PHASE (stated first, per the contract; FINAL at the stop, 2026-10-04):**
- **A Variorum mail draft was NEVER SEEN ON SCREEN on this machine** — this M3's Apple Mail has no
  account, so BOTH doors (Send Report… and Help ▸ Send Feedback…) landed in Mail's own Add Account
  sheet (F-W5, measured; the compose service even reports success, so Variorum cannot tell). The
  drafts' contents and the attachment's identity are pinned headless; the first on-screen draft is
  her new computer's arm (f) if Mail is set up there. Whether the doors should do more for a Mac
  without a mail account is QUESTIONS **#181 (i)** — hers, not decided here.
- **The REAL MetricKit delivery was not observed** (no real crash; Apple controls the timing). The
  walk exercised everything below MetricKit's payload object through the INJECTED synthetic payload;
  the payload extraction is one line, unpinnable outside MetricKit. MetricKit inside the App Sandbox
  is UNCONFIRMED by any source the lookup found — recorded, never claimed. A beta-era crash on an
  opted-in Mac is the opportunistic last leg (R-13r-5's accepted trade-off).
- **The U3 walk is STAGED, never run** (piece 6): no release, no publish, nothing against the public
  feed; the public appcast is untouched.
- **The full Mac and core suites were not run** (the brief names the touched families; the ladder's
  "suite green" is the phase's). The one red in the families run is the PRE-EXISTING runbook drift
  already queued as **19e** (`DataSafetyRunbookTests.theShippedRunbookAndTheRepoCopyAreOneDocument`).
*[removed for publication]*
  zero schema, zero `Shared/`, zero mobile-target files (the scope check below) — so the mobile
  target is untouched by construction and was not rebuilt.
- **For the ladder (flagged, not decided):** Help ▸ Send Feedback… is UNDECLARED in the capability
  registry (the What's New / Open the Tutorial precedent — a P-1 reading); the two pane acts ARE
  declared `.surface`-only (the Data Safety precedent); `CrashDiagnosticSubscriber` is `@unchecked
  Sendable` (its one stored property is an immutable `@Sendable` closure); the compose service's
  delegate is the app-long `LiveSupportMailRoads.shared`, holding one pending failure road at a
  time; MetricKit's `MX*` API is "to be deprecated" in the macOS 27 SDK (no warning; the new API is
  macOS 27+).

**Session start (2026-10-04 ~21:10Z):** toolchain re-read — macOS 27.0 (26A428) · Xcode 27.0
(27A266a) · `xcode-select -p` = `/Applications/Xcode.app/Contents/Developer` (the pinned pair).
Zero instances (`pgrep -fl 'Variorum.app/Contents/MacOS'`: no match). HEAD `32b97fdc` = origin, tree
clean, commit count 4892. Brief read in full in this session: the plan's KICKOFF, the SITTING RECORD
(R-13r-1…9, R-13r-5 above all), the U3 section with every amendment (R-13r-10…16, the walk arms,
the hazards, SIZING), ENVIRONMENT TRAPS, THE LADDER, the LIVE STATUS from THE RESUME RECORD down
(the toolchain pair; the SITE-SIDE REPORT — `support@stargazing.tech` is LIVE; the "U3-B — OPEN"
bullet), the U2 RECORD's walk sheet (W-0…W-10 + its STOP rules — the form this unit's sheet
follows), the U3-A RECORD in full; `notes/SessionResiliencyProtocol.md`; the 17 ledger's P15 entry
and its FIXED row (the key-in-error-description road closed at origin by `StoreKey
.redactedDescription(of:)` + `RedactedKeyedStatementError` — this unit's surface starts from a
closed road and adds no new reader of any GRDB error).

**A FACT READ BEFORE RELYING ON IT — the MetricKit road, from THIS machine's macOS 27.0 SDK
headers (not a web claim):** `MXMetricManager` / `MXMetricManagerSubscriber` /
`MXDiagnosticPayload` / `MXCrashDiagnostic` stay `macos(12.0)`, now marked
`API_DEPRECATED(…, macos(12.0, API_TO_BE_DEPRECATED))` — the "to be deprecated" sentinel, which
emits no warning — in favour of a new Swift `MetricManager` / `DiagnosticReport` family that is
`@available(macOS 27.0, …)` (the `.swiftinterface`). The deployment target is macOS 26 and AppSpec
§1 rules "no availability gating", so **R-13r-5's `MXCrashDiagnostic` subscriber road stands as
ruled**; the new API is a post-macOS-27-floor migration, recorded here and nothing more.
`MXDiagnosticPayload.crashDiagnostics` and `pastDiagnosticPayloads` are `macos(12.0)`;
`MXCrashDiagnostic.exceptionReason` is `macos(14.0)`.

**Pieces (the SIZING bullet's U3-B list; placement-independent pieces FIRST, then THE PLACEMENT
PROPOSAL and a STOP for the architect's ruling, then the faces):**
1. The crash-report OPT-IN + the registration seam + the subscriber + the owner + the report store —
   **DONE (this commit).** (The store joined piece 1: the receive road needs somewhere to end.)
   - `Features/Diagnostics/CrashReporting.swift` (Mac target only): `CrashReportingPreference` — a
     LOCAL preference (`variorum.crashReports.optIn`, this app's container, never synced) where ONLY
     an explicit boolean YES is on (absent, `false`, `"1"`, `"YES"`, `2`, … all read OFF);
     `CrashDiagnosticRegistration` — THE INJECTED SEAM (`MetricKitRegistration` = `MXMetricManager
     .shared.add/remove` in production); `CrashDiagnosticSubscriber` — `nonisolated`, implements
     `didReceive(_: [MXDiagnosticPayload])` ONLY (no metrics callback, so no metrics are ever
     delivered) and keeps each `MXCrashDiagnostic`'s own `jsonRepresentation()` — one report per
     crash; a hang/CPU/disk diagnostic in the same payload is never stored, shown or sent (R-13r-5
     names `MXCrashDiagnostic`); `CrashReporting` — the ONE owner on `VariorumAppDelegate` (the
     `appearance`/`updates` precedent): registers at init ONLY when the preference already says
     yes, `set(_:)` registers/unregisters the same subscriber, `receive` stores only while ON (a
     delivery racing the switch to OFF is dropped), turning OFF never deletes what already arrived.
   - `Features/Diagnostics/CrashReportStore.swift`: one file per report,
     `Application Support/Diagnostics/Crash Reports/crash-report-<UTC stamp>-<8 hex>.json` in the
     app's own container — a SIBLING of the library folder (`Application Support/<variant>/`), never
     inside it, so no backup/export/sync carries one; the BYTES exactly as MetricKit handed them;
     `text` is the bytes as UTF-8 or nil (bytes that are not text are never shown as if they were —
     and so can never be sent, see piece 3); `heading` is READ OUT of the report
     (`diagnosticMetaData` app/OS versions), never added to it.
   - Pins: `VariorumTests/CrashReportingTests.swift` (10 — a fresh install is OFF and REGISTERS
     NOTHING; seven strange stored values register nothing; five launches while off never
     subscribe; yes subscribes once, no unregisters the SAME subscriber; a remembered yes subscribes
     at launch; a delivery while on lands byte-for-byte and a late delivery after off is dropped;
     the subscriber takes diagnostics and never metrics (by ObjC selector); the app's own owner
     rides MetricKit and starts off; the store's order/round-trip/delete; the heading read out).
     **Run: `Test run with 10 tests in 1 suite passed`, no `skipped:` line** (log
     `App/Variorum/DerivedData/13r-u3b/p1-test.log`; build log `p1-build.log` — no warning in any
     new file). Red-on-old by construction (no type existed); the mutation run is the finals'.
   - NOT pinnable, recorded: the extraction from a real `MXDiagnosticPayload` (MetricKit's types
     cannot be constructed outside MetricKit) — it is the one line `payloads.flatMap {
     $0.crashDiagnostics ?? [] }.map { $0.jsonRepresentation() }`.
2. The DEBUG-only synthetic-payload door — **DONE (this commit).**
   - `Features/Diagnostics/SyntheticCrashReport.swift`, gated THREE times: `#if DEBUG` (a Release
     build compiles it to nothing); the launch environment `VARIORUM_SYNTHETIC_CRASH_REPORT=<path>`
     (the `VisualWalkProbe` precedent); and the opt-in itself — the bytes go into the REGISTERED
     subscriber's own delivery (`deliverAsMetricKitWould`), so an OFF app has nothing to deliver
     into, exactly as with MetricKit. Everything below MetricKit's payload object is the real road
     (subscriber → main-actor hop → the owner's ON gate → the store → the list). The app is
     sandboxed, so the walk writes the file under the Debug container's own `Data/tmp/`. It NSLogs
     its outcome (`[13r-u3b] synthetic crash report: delivered | offSoNothingDelivered | …`) for
     the walk to read. Called once from `applicationDidFinishLaunching`, inside the existing DEBUG
     block.
   - Pins: `VariorumTests/SyntheticCrashReportTests.swift` (4 — not asked → nothing; OFF + asked →
     nothing delivered, the folder untouched; ON + asked → the report arrives verbatim through the
     subscriber; an unreadable path → nothing). **Run with piece 1's suite: `Test run with 14 tests
     in 2 suites passed`, no `skipped:` line** (`13r-u3b/p2-test.log`; no warning in any new file).
3. The support door's MAIL DRAFT machinery + Help ▸ Send Feedback… — **DONE (this commit).**
   - **EXTERNAL FACTS (the unit's one read-only Sonnet lookup, 2026-10-04; Apple-documented vs
     community kept apart):** a `mailto:` cannot carry an attachment (**Apple QA1018**, RFC 6068) and
     opens in the user's DEFAULT mail app (community, medium-high); `NSSharingService(.composeEmail)`
     takes `recipients`/`subject` + a body string + file URLs (**Apple-documented**) but is
     effectively Apple Mail-only (`canPerform` true only when Mail is usable — community,
     medium-high); its behaviour with NO Mail account is UNCONFIRMED. MetricKit: diagnostics reach
     Developer-ID apps with no documented channel requirement; crash diagnostics do NOT depend on
     the "Share with App Developers" consent (Apple DTS + a MetricKit engineer, on iOS — macOS
     UNCONFIRMED); diagnostics are documented as delivered immediately (macOS 12+), in practice on
     the relaunch after a crash; MetricKit inside the App Sandbox is UNCONFIRMED by any source —
     so the REAL delivery stays "opportunistic" in this record, never claimed; Xcode 27's Debug ▸
     MetricKit ▸ Simulate MetricKit Payloads exists, macOS support UNCONFIRMED. A crash report's
     `exceptionReason`/`terminationReason` text is whatever the thrower composed, so it could carry
     app data — Apple DTS says to treat MetricKit data as potentially personal — which is exactly
     why the report is shown VERBATIM before anything can leave (the P15 road stays closed: this
     unit reads no GRDB error, and the subscriber's bytes are MetricKit's own).
   - `Features/Diagnostics/SupportDraft.swift` — THE ONE BUILDER (pure): `support@stargazing.tech`
     (R-13r-9, the LIVE mailbox); the FEEDBACK draft = three empty lines to write in, a rule, then
     "Variorum 0.9.0 (4893)" and "macOS 27.0 (26A428)" — the versions and NOTHING else; the CRASH
     draft = the same shape with "Attached: <file> — the crash report exactly as Variorum showed it
     to you." and the report's OWN FILE as the attachment (the bytes the surface shows — pinned
     equal); `attachingByHand()` = the fallback twin; `mailtoURL` = RFC 6068-clean (unreserved-only
     percent-encoding, CRLF line breaks, subject + body only). `Versions.osLine` reads the build
     out of `operatingSystemVersionString`, never invents one. `SupportCopy` holds the words.
   - `Features/Diagnostics/SupportMail.swift` — the side effect, behind the injected
     `SupportMailRoads` (`LiveSupportMailRoads` in production): NO attachment → `mailto:` (her
     default mail app); WITH the attachment → the compose-email service when it can take the draft;
     when it cannot, or reports a failure that is not HER cancel (`isHerOwnCancel` —
     `NSUserCancelledError` in the Cocoa domain), the FALLBACK: the file shown in Finder, then the
     plain draft naming it (PROVISIONAL, QUESTIONS #181 (b)); nothing opening at all → the door's
     refusal ("…nothing was sent."). **No road can send** — the protocol has no such member.
   - **Help ▸ Send Feedback…** (`EditorCommands`, the Help group's END after a divider, always
     enabled — it needs no window or store): `SupportMail.open(.feedback(.thisMac()))`, its refusal
     through the session's status seam, or a plain alert when no store is open (a door that did
     nothing must speak). **UNDECLARED in the capability registry on the What's New / Open the
     Tutorial precedent — FLAGGED FOR THE LADDER as a P-1 reading, not decided here** (#181 (d)).
   - Pins: `VariorumTests/SupportDraftTests.swift` (12 — the feedback draft byte-exact; the running
     app's versions are the bundle's own; the OS line read never guessed; the crash draft attaches
     the report's own file and the by-hand twin names it; WHAT IS SENT IS WHAT WAS SHOWN (the
     attachment's bytes == the stored report's text); the mailto form RFC 6068-clean and
     round-tripping; feedback → `mailto:` only; a report → compose with the attachment; no compose →
     reveal + the by-hand draft; a late compose failure falls back while her cancel does not;
     nothing opening speaks the refusal; the Help door's source line). **Run with pieces 1–2 + the
     registry walk, What's New, shell chrome and chord legibility: `Test run with 74 tests in 7
     suites passed`, no `skipped:` line** (`13r-u3b/p3-test.log`; no warning in any touched file).
   - QUESTIONS **#181** opened (a)–(g): the two roads, the by-hand fallback, the words, the Help
     placement, crash-only collection, OFF keeps received reports, no cap.
4. THE PLACEMENT PROPOSAL (the in-batch fork) — **WRITTEN (this commit); THE SESSION STOPS HERE
   for the architect's ruling.**

   **THE PLACEMENT PROPOSAL — where the crash-report opt-in and the Diagnostics surface live in
   Settings.** The surveyed facts first (read from `SettingsShape.swift`, `AppSettingsView.swift`,
   `DataSafetyPane.swift`, `ProtectionPane.swift`; the window is a FIXED 720×520 with a leading pane
   list + the search field):
   - **General** — "the voice, the colours, light and dark, and how the app confirms what it did";
     deliberately THE SHORT PANE (KnownIssues row 59's fold: 13u4 S1 split the old tab and reordered
     it so the appearance choice is on screen when Settings opens). Today: Voice · Light & dark (this
     Mac) · Palette (the tallest control in Settings) · Confirmations · **Updates** (U3-A's "Check for
     updates automatically" — rendered ONLY in a live Release build, P-2).
   - **Editor** (10 rows: the page, switching modes, ownership badges, while you write) · **Takes** (2)
     · **Writing** (3 synced document habits) · **Shortcuts** (the keyboard map + dictionary) ·
     **Tags** (the tag manager) — all about writing; none fits.
   - **Protection** — the passphrase, Standard/Castle, escrow, the ways back in: custody, not this.
   - **Data Safety** — the LONGEST pane, seven sections, all about THE LIBRARY's safety: copies of
     your library · a second folder · plain-text copies · the decrypted export · "Your account" (is
     anything still only on this Mac) · restoring a copy · the backup log. Blurb: "Backups, how fresh
     they are, and what restoring one does."
   - **Acknowledgments** — open-source notices.
   - The surface itself, whatever the pane (shared by every option): the opt-in TOGGLE with the
     privacy story stated plainly under it (off unless you turn it on; macOS hands Variorum a report
     after a crash, usually at the next launch; reports stay on this Mac and appear below exactly as
     they arrived; nothing is sent unless you press Send, which opens an email draft to
     support@stargazing.tech with the report attached, for you to read first; this Mac only); then
     the RECEIVED REPORTS, newest first — each a card with its heading (the versions read out of it)
     and received date, the report's raw JSON ALWAYS VISIBLE in a bounded, scrollable, selectable
     monospaced box (verbatim means shown before Send is reachable, never behind a disclosure), and
     **Send…** (the support door's draft with the report attached) + **Delete** (from this Mac);
     an empty list says so in one quiet line. A catalog row so Settings search finds it ("crash",
     "report", "diagnostics", "privacy", "metrickit", "support"…).

   **OPTION A (RECOMMENDED) — a TENTH PANE, "Diagnostics", between Data Safety and Acknowledgments**
   (symbol `stethoscope`; blurb along the lines of "Crash reports — off unless you turn them on, and
   never sent without you."). The toggle at the top, the received reports under it, nothing else.
   *For:* the brief and the plan already NAME the surface "Diagnostics" — a pane of that name is where
   anyone (a friend, Settings search) looks; the privacy promise reads best alone at the head of its
   own pane rather than as the eighth section of another; the verbatim JSON is long (a real report is
   hundreds of lines) and gets a pane's height without pushing any existing control under a fold;
   every existing pane keeps its shape and its blurb (row 59's fold work untouched; Data Safety's
   seven sections untouched); one pane = one concern (P-9's spirit); it is the shape a later
   "diagnostics" thing (a hang report, an exported log) would join. *Against:* a tenth pane for one
   toggle and a list that is empty for nearly everyone — the empty state must be calm, one line.
   Ten rows fit the fixed pane list with room (measured by the row metrics: ~27 pt a row).

   **OPTION B — a "Crash reports" section at the END of Data Safety** (after the backup log).
   *For:* Data Safety is already the pane about what exists on this Mac and what leaves it (copies,
   exports, the "is anything still only here" evidence), and crash reports are another local
   record; no new pane. *Against:* Data Safety is about THE LIBRARY's safety and crash reports are
   about THE APP — a friend looking for "crash" will not guess "Data Safety"; it is the longest pane
   already, so the toggle and its promise land at the very bottom of a long scroll and the verbatim
   JSON makes it longer still; the pane's blurb would have to change to admit a second subject.

   **OPTION C — the toggle in GENERAL beside Updates, the reports behind a "Show Crash Reports…"
   door** (a sheet). *For:* the two app-level settings that concern the outside world sit together
   (Updates: asks stargazing.tech; Crash reports: never sends); General is "the whole app".
   *Against:* General is the deliberately SHORT pane (row 59's fold history); its Updates section is
   Release-only while crash reporting exists in every build, so the pairing is absent exactly where
   the walk runs; a sheet inside Settings is a second surface to build and puts the verbatim evidence
   one click away from the promise that says it is shown.

   **NOT PROPOSED, recorded:** Protection (custody, a different trust surface); a second Send
   Feedback… door inside the pane (the act already has its door in the Help menu — one act, one
   door, P-1's spirit; the pane's caption may NAME Help ▸ Send Feedback… in words).

   **Resuming after the ruling:** piece 5 builds the toggle + the surface into the ruled place (the
   `CrashReporting` owner handed to `AppSettingsView` like `appearance`/`updates`; the catalog row;
   `rowIDsRendered` updated; P-8 voice chrome; pins incl. the pane-shape and search pins), then
   piece 6 stages the walk sheet, then the finals.
5. The faces, to the architect's ruling — **DONE (this commit).** RULED (the LIVE STATUS, `868b8096`):
   **Option A — a TENTH Settings pane "Diagnostics" between Data Safety and Acknowledgments**,
   `stethoscope`, the blurb and captions approved as FUNCTIONAL copy (13s re-voices), the
   exclusions (Protection; no second Send Feedback door in the pane) ratified.
   - `SettingsShape.swift`: `SettingsPane.diagnostics` (title, blurb "Crash reports — off unless you
     turn them on, and never sent without you.", `stethoscope`) between `.dataSafety` and
     `.acknowledgments`; the catalog row `crashReports` (title = `DiagnosticsCopy.toggleTitle`
     "Collect crash reports"; keywords crash/report/diagnostics/privacy/metrickit/support/
     feedback/telemetry/analytics…) so Settings search finds it.
   - `AppSettingsView.swift`: a `crashReports: CrashReporting?` input (optional like `protection` —
     no owner, no pane: P-2, never a second owner), `rowIDsRendered[.diagnostics] =
     ["crashReports"]`, the pane in `paneBody`. `VariorumApp` hands it `appDelegate.crashReports`.
   - `Features/Settings/DiagnosticsPane.swift` (its own file, P-9 — the pane composes in one line):
     Section "Crash reports" = the Toggle (bound to the owner's `isOn`/`set`) + the PROMISE caption +
     "Variorum has no analytics. To write about anything else, use Help ▸ Send Feedback…." (the act's
     door named in words, never a second door); Section "Received" = the calm one-line empty state
     (OFF: "None. Nothing is collected while this is off." · ON: "None yet — that's the usual
     state.") or one `CrashReportCard` per report, newest first; a draft that could not open says so
     in a caption under the reports (Settings has no status seam — the Data Safety `note` shape).
     The pane re-reads the folder on appear. `CrashReportCard`: the heading read out of the report,
     "Received <date>", the report's text in `Text(verbatim:)` (no Markdown, no localisation) inside
     a bounded 180-pt, two-axis-scrollable, SELECTABLE monospaced box on the voice's `card`/`line`/
     `ink` tokens — ALWAYS visible, never behind a disclosure; then **Send Report…** (rendered ONLY
     when the report's bytes were shown as text) and **Delete Report** in `VoicedButtonStyle`
     (P-8). `DiagnosticsCopy.swift` holds every word.
   - **P-1, on the Data Safety precedent:** the two acts are DECLARED — `.sendCrashReport` ("Send
     Report…") and `.deleteCrashReport` ("Delete Report"), `.surface` door ONLY, app scope (never
     ⌘K or a menu: a report is sent from where it was read — the reason is in `Capability.swift`);
     `DiagnosticsPane.surfaceCapabilities` joins the registry walk's union as a JUSTIFIED EDIT line.
   - Delete acts at once, no confirm (a local diagnostic file, not writing) — PROVISIONAL, added to
     QUESTIONS #181 as (h).
   - Pins: `VariorumTests/DiagnosticsPaneTests.swift` (8 — the tenth pane's place/name/symbol and
     General still ≤5 rows; search reaches it in six of her words; OFF composes the toggle + promise
     + pointer + the OFF empty line and NOT the ON one; ON-empty the reverse; the promise's words say
     what the code does (names the address and the card's own verb); a report's card composes its
     text VERBATIM + the heading + both verbs, and the pane hosts with it; a not-text report shows
     the not-text line and NO Send; both acts `.surface`-only). The 17f/P47 composition road
     (`SurfaceComposition`), so a deleted `Text` fails, not only a changed constant.
     **Run with the Settings shape, registry walk, no-literal-colour and the three earlier U3-B
     suites: `Test run with 79 tests in 7 suites passed`, no `skipped:` line**
     (`13r-u3b/p5-test.log`). The build's one warning in a touched file
     (`AppSettingsView.swift` — `spec(paths:joinAll:)` actor isolation, in `PromoteTagsSheet`) is
     PRE-EXISTING: U3-A's logs carry it at its old line number.
6. THE U3 WALK — STAGED (R-13r-16's combined public road) — **DONE: STAGED, never run (this
   commit).** The sheet is below. This session runs nothing in it: no release, no publish, nothing
   against the public feed, no `/Applications`, no real store.

   **THE U3 WALK — STAGED (R-13r-16: the COMBINED PUBLIC-ROAD WALK, on HER NEW COMPUTER).**
   - **Who does what:** `[O]` = the orchestrator, on the M3, before the sitting (the releases are
     published per R-13r-15/16 BEFORE she sits — they are not this session's to run). `[HER]` = her
     hands, on the NEW COMPUTER.
   - **The `!`-road lesson binds:** every Terminal block below sets its own values INLINE; nothing
     carries between blocks. Paste one block at a time.
   - **On the new computer she is a NEW USER:** she signs Variorum into NOTHING during the walk (a
     sync sign-in would pull her real library into the walk install — out of this walk's letter;
     that is a later decision, not an arm). Her new computer's own `/Applications` is the install
     target, exactly as a friend's: the M3's "every account sees `/Applications`" hazard (the U2
     walk) is a same-machine fact and does not apply on another Mac.
   - **Captures:** ⌘⇧3 / ⌘⇧4 land on the new computer's Desktop by default; she brings them to the
     M3 however she likes (AirDrop), and `[O]` files them in the gitignored
     `notes/plans/13r-screens/u3-walk/`. Each arm names its capture (`U3-a1` …).
   - **THE PUBLIC ROAD'S SHAPE DURING THE WALK (the one staging subtlety):** the `/variorum` page's
     data file points at **0.9.0** (what she downloads) while the appcast already carries **0.9.1**
     (what Check for Updates… finds). The page moves to 0.9.1 only AFTER the walk (R-13r-16:
     "After the walk the page's data file points at the latest 0.9.x").

   - **N-0. [O] STAGING, on the M3, before the sitting** (the R-13r-15 exemption; the site runbook
     is `~/dev/stargazing.tech/stargazing-tech/notes/variorum-releases.md`, pre-read in the LIVE
     STATUS):
     - **(a) The no-public-entry hazard, re-checked rather than assumed:** her M3 daily drive must be
       either the PRE-SPARKLE `1.0 (1)` (no updater exists in it) or a stamped build whose
       `CFBundleVersion` exceeds every 0.9.x entry's. `/usr/libexec/PlistBuddy -c 'Print
       :CFBundleShortVersionString' -c 'Print :CFBundleVersion' /Applications/Variorum.app/Contents/Info.plist`
       — a stamped build BELOW a published entry is a STOP (her own app would be offered it).
     - **(b) Her two bundle items done:** the Finder Automation toggle (`release.sh` refuses at
       preflight without it) and the 0.9.0 notes rewritten/okayed.
     - **(c) 0.9.0:** the version-bump commit if needed (R-13r-6's adjudicated reading; 0.9.0 is
       already the Mac target's MARKETING_VERSION) → `Tools/Release/release.sh --version 0.9.0`
       (its `make-appcast` step reads HER Keychain — the one her-adjacent moment) → the site
       runbook in its LOCKED order: DMG to `dl.stargazing.tech` first, then
       `Tools/Release/verify-published.sh dmg <that DMG>` PASS, then the appcast + `src/data/
       variorum.json` → 0.9.0, deploy, then `verify-published.sh appcast <that appcast.xml>` PASS.
     - **(d) 0.9.1:** its notes `App/Variorum/Variorum/Features/WhatsNew/ReleaseNotes-0.9.1.md`
       drafted functional-honest (release mode REFUSES without them; her look invited) → the bump
       commit to 0.9.1 → `Tools/Release/release.sh --version 0.9.1` (the durable release feed
       `~/Library/Developer/Variorum/Releases/feed` accumulates, so this appcast carries BOTH items)
       → DMG first + `verify-published.sh dmg` PASS → the appcast + `verify-published.sh appcast`
       PASS → **the page's data file STAYS at 0.9.0** (see the shape above).
     - **(e) From the M3, the public state the walk expects:**
       ```sh
       curl -s https://stargazing.tech/variorum/appcast.xml | grep -oE '<sparkle:shortVersionString>[^<]+' | sort -u
       ```
       Expect both 0.9.0 and 0.9.1.
       ```sh
       curl -sI https://dl.stargazing.tech/variorum/Variorum-0.9.0.dmg | head -1; curl -sI https://dl.stargazing.tech/variorum/Variorum-0.9.1.dmg | head -1
       ```
       Expect two `200` lines (two requests — well inside the host's 10-per-10-s limit).
       And `https://stargazing.tech/variorum` in a browser reads **0.9.0** with its download button.
     - **(f) [O]** `date -u +'%Y-%m-%d %H:%M:%S'` — the walk's START, recorded here.

   - **N-1. [HER] Download, on the new computer** — arm (a)'s first half.
     - Safari ▸ `https://stargazing.tech/variorum` → the page reads 0.9.0 → the download button.
       **CAPTURE U3-a1** (the page).
     - In Terminal (Applications ▸ Utilities ▸ Terminal), one block:
       ```sh
       xattr -p com.apple.quarantine ~/Downloads/Variorum-0.9.0.dmg; spctl -a -t open --context context:primary-signature -vv ~/Downloads/Variorum-0.9.0.dmg 2>&1 | head -2
       ```
       Expect a quarantine line (Safari's), then `accepted` / `source=Notarized Developer ID`.

   - **N-2. [HER] ARM (a) — THE DMG WINDOW on the downloaded image:** double-click
     `~/Downloads/Variorum-0.9.0.dmg`.
     - EXPECT: macOS verifies it; the window opens at a fixed size with NO toolbar or sidebar, the
       Variorum icon on the LEFT, the Applications folder on the RIGHT, a plain grey arrow between
       them with "Drag Variorum to Applications" under it. No warning blocks it. **CAPTURE U3-a2.**
     - U3-A's open question for this arm: if she can, capture it again with the system in DARK
       appearance (System Settings ▸ Appearance ▸ Dark, reopen the DMG window) — whether Finder keeps
       the icon labels readable over the near-white background was not measurable without Finder
       access. **CAPTURE U3-a3** (dark), then set her appearance back.

   - **N-3. [HER] THE DRAG-INSTALL:** drag Variorum onto the window's Applications folder. Eject the
     DMG. Then, one block:
     ```sh
     /usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' /Applications/Variorum.app/Contents/Info.plist; spctl -a -vv /Applications/Variorum.app 2>&1 | head -3
     ```
     Expect `0.9.0`, then `accepted` / `source=Notarized Developer ID`.

   - **N-4. [HER] ARM (b) — THE FIRST OPEN, and DAY 1 of use:** open Variorum from Launchpad or
     `/Applications` (NOT from the DMG).
     - EXPECT the OS's one-time question: "“Variorum” is an app downloaded from the Internet. Are you
       sure you want to open it?" → **Open**. **CAPTURE U3-b1.** (That question is the OS's, expected
       once per newly downloaded copy.) A BLOCK dialog ("cannot be opened because Apple cannot check
       it", "is damaged", "unidentified developer") is a STOP.
     - EXPECT a fresh library (the seeded Welcome shelf, the field guide), and **NO popup of
       Variorum's own**: no Sparkle "Check for updates automatically?", no What's New (a fresh
       install records its version silently), no backup offer. **CAPTURE U3-b2.**
     - **Day 1, the calm proof:** leave Variorum frontmost and untouched for **3 minutes** (the
       cadence's moment is 2 minutes open + 20 s without typing). EXPECT still NOTHING — day 1 shows
       neither ask. **CAPTURE U3-b3** at the 3-minute mark.
     - Variorum ▸ About Variorum reads **0.9.0 (<its build>)**. **CAPTURE U3-b4.**

   - **N-5. [HER] ARM (f) — HELP ▸ SEND FEEDBACK… (NOT SENT):** Help ▸ **Send Feedback…**.
     - EXPECT her DEFAULT mail app opens a new message: To `support@stargazing.tech`, Subject
       "Variorum feedback", the body three empty lines, a rule "———", then "Variorum 0.9.0 (<build>)"
       and "macOS <her OS> (<build>)" — and nothing else. **CAPTURE U3-f1.** Close it UNSENT (Don't
       Save / Delete Draft). Nothing was sent.
     - (Measured on the M3 at U3-B's walk: with no Mail account, BOTH doors land in Mail's Add
       Account sheet and no draft appears — F-W5. So this arm may be the FIRST time a Variorum draft
       is seen on screen at all.)
     - **If Mail has no account on the new computer,** Mail's own account setup opens instead: that
       is the OS's state on a new Mac, not a Variorum failure — **CAPTURE U3-f2**, cancel it, and it
       is a FINDING for QUESTIONS #181 (a) (whether plain feedback should keep the default-mail-app
       road). Nothing was sent either way.

   - **N-6. [HER] ARMS (d) + (c) — THE UPDATE from the PUBLIC FEED, then WHAT'S NEW once:**
     - Variorum ▸ **Check for Updates…**. EXPECT "A new version of Variorum is available! Variorum
       0.9.1 is now available—you have 0.9.0." with 0.9.1's notes. **CAPTURE U3-d1.** If the alert
       shows "Automatically download and install updates in the future", leave it UNticked (the
       friend's default road; read from Sparkle 2.10.0: that box writes `SUAutomaticallyUpdate`,
       never the answer the day-3 ask reads, so arm (e) survives either way).
     - **Install Update** → download → **Install and Relaunch**. EXPECT Variorum quits and relaunches
       on its own; no password should be asked (the app is hers, in her own `/Applications` copy) —
       if one is, capture it, enter it, and note it. **CAPTURE U3-d2.**
     - **ARM (c):** at the relaunch EXPECT the **What's New** sheet: "What's new in Variorum 0.9.1",
       0.9.1's notes, Continue. **CAPTURE U3-c1.** Continue.
     - Variorum ▸ About reads **0.9.1 (<its build>)**, and the library from N-4 is still there.
       **CAPTURE U3-d3.**
     - **⌘Q, then open Variorum again:** EXPECT NO What's New (shown once). **CAPTURE U3-c2.**
     - One block:
       ```sh
       /usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' /Applications/Variorum.app/Contents/Info.plist; spctl -a -vv /Applications/Variorum.app 2>&1 | head -3; codesign --verify --deep --strict /Applications/Variorum.app && echo "seal valid"
       ```
       Expect `0.9.1`, `accepted` / `Notarized Developer ID`, `seal valid`.

   - **N-7. [HER] ARM (e) — THE CALM-ASKS CADENCE, day 3 (the update ask):**
     - **⌘Q Variorum first** (the counter is written with the app closed).
     - One block — make the next launch day 3 (U3-A's container-path recipe; the shipped numbers are
       never shortened — only the counter is moved):
       ```sh
       defaults write ~/Library/Containers/io.lduarte.Variorum/Data/Library/Preferences/io.lduarte.Variorum variorum.calmAsks.daysOfUse -int 2
       ```
       ```sh
       defaults write ~/Library/Containers/io.lduarte.Variorum/Data/Library/Preferences/io.lduarte.Variorum variorum.calmAsks.lastUseDay -string 2000-01-01
       ```
       ```sh
       defaults read ~/Library/Containers/io.lduarte.Variorum/Data/Library/Preferences/io.lduarte.Variorum variorum.calmAsks.daysOfUse
       ```
       Expect `2`.
     - Open Variorum. EXPECT NOTHING at launch. Leave it frontmost and untouched; within about **2½
       minutes** EXPECT Sparkle's own window: "Check for updates automatically?" — **Check
       Automatically** / **Don't Check**, and NO system-profile option. **CAPTURE U3-e1** (note the
       minutes after launch).
     - Choose **Check Automatically**. Then Variorum ▸ Settings… ▸ **General**: the **Updates**
       section's "Check for updates automatically" reads ON, and the "You haven't chosen yet…"
       sentence is gone (the window and the checkbox are Sparkle's ONE setting). **CAPTURE U3-e2.**

   - **N-8. [HER] ARM (e) — day 5 (the backup-folder offer):**
     - **Writing of her own first** (the offer waits for it): ⌘N, type one sentence of her own into
       the new note. Then **⌘Q**.
     - Make the next launch day 5:
       ```sh
       defaults write ~/Library/Containers/io.lduarte.Variorum/Data/Library/Preferences/io.lduarte.Variorum variorum.calmAsks.daysOfUse -int 4
       ```
       ```sh
       defaults write ~/Library/Containers/io.lduarte.Variorum/Data/Library/Preferences/io.lduarte.Variorum variorum.calmAsks.lastUseDay -string 2000-01-01
       ```
       ```sh
       defaults read ~/Library/Containers/io.lduarte.Variorum/Data/Library/Preferences/io.lduarte.Variorum variorum.calmAsks.daysOfUse
       ```
       Expect `4`.
     - Open Variorum, leave it frontmost and untouched. Within about **2½ minutes** EXPECT the quiet
       OFFER toast at the bottom: "Keep a copy of your backups in iCloud Drive?" — **Not Now** ·
       **Set Up…** · ✕. It shows for about 6 seconds. **CAPTURE U3-e3** quickly.
     - **Set Up…** (if the toast has gone, see the re-arm below): EXPECT the three-door iCloud Drive
       sheet. **CAPTURE U3-e4.** Close it with **Not Now** — the ask retires.
     - **The re-arm, if she missed the 6-second toast:** ⌘Q, then the two `defaults write` blocks
       above again PLUS this one (it clears the day the toast took):
       ```sh
       defaults delete ~/Library/Containers/io.lduarte.Variorum/Data/Library/Preferences/io.lduarte.Variorum variorum.calmAsks.lastAskDay
       ```
       and reopen. (A toast that times out counts as ignored, and returns ONCE more after 7 further
       days of use — the cadence's own rule; the re-arm just brings it back today for the walk.)

   - **N-9. [OPTIONAL — NOT in R-13r-16's letter; the orchestrator's call] ARM (g) — CRASH
     REPORTING IS OFF on a friend's road:** Variorum ▸ Settings… ▸ **Diagnostics** (the tenth pane,
     between Data Safety and Acknowledgments). EXPECT "Collect crash reports" OFF, the promise under
     it, and "None. Nothing is collected while this is off." **CAPTURE U3-g1.** One block:
     ```sh
     defaults read ~/Library/Containers/io.lduarte.Variorum/Data/Library/Preferences/io.lduarte.Variorum variorum.crashReports.optIn
     ```
     EXPECT `The domain/default pair … does not exist` — the opt-in was never set. Whether she then
     turns it ON on this computer (so a real beta-era crash, if one ever happens, is the
     opportunistic real-delivery witness R-13r-5 accepted) is HER choice, not an arm.
     New-user extra, optional: the field guide's "export — it's all yours" lesson now ends with
     R-13r-14's backups passage, readable in place.

   - **N-10. [O] Back on the M3:**
     - **(a) The captures** into `notes/plans/13r-screens/u3-walk/` (gitignored); list them.
     - **(b) The page moves to 0.9.1** (the site runbook's data-file + deploy legs), now that the
       walk has run.
     - **(c) THE VERDICT, into this record. PASS = all of:** U3-a2 the DMG window's drag layout on
       the DOWNLOADED image · N-3 `spctl` accepted the installed app · U3-b1 the OS's question, not
       a block · U3-b2/b3 no Variorum popup at first open and none on day 1 · U3-f1 (or f2) a
       pre-filled feedback draft on screen, NOT sent · U3-d1–d3 0.9.1 found on the PUBLIC feed and
       installed over the XPC road, library intact, seal valid · U3-c1/c2 What's New once, not on
       the relaunch · U3-e1 the update ask on day 3 at a calm moment, never at launch · U3-e2 the
       Settings checkbox reflects the answer · U3-e3/e4 the backup offer on day 5 (never the update
       ask's day), Set Up… → the sheet, Not Now retires it.

   - **STOP RULES, any step:**
     - a Gatekeeper BLOCK (on the DMG or the app);
     - a Sparkle "An error occurred…" alert (capture it, ⌘Q, report) — or Check for Updates…
       reporting 0.9.0 is the newest (the 0.9.1 entry is not live: N-0 (d)/(e) were not done);
     - the installer failing, or a relaunch that still reads 0.9.0 (capture About);
     - ANY Variorum popup at the first open or on day 1 (the R-13r-11 principle broken — capture it);
     - a mail draft that was SENT without her pressing Send (it cannot happen by construction; if it
       ever does, stop everything);
     - anything touching her M3's Variorum or its real store — this walk never does.
     **The walk publishes nothing beyond N-0's two releases, never touches the M3's `/Applications`
     or real store, and uses NO feed override anywhere (R-13r-16).**
   - **Left in place, not cleaned:** the new computer's install (it is hers — it will self-update
     *[removed for publication]*
     debris on the M3 stay for the closeout's sweep, as the U2 record says.
7. Finals — **DONE (this commit).**
   - **MUTATION RUN IN FLIGHT (named before it starts, per the protocol's addendum 2; the committed
     tree `f2d710b0` is the pre-revert copy):** four production mutants applied together —
     (M1) `CrashReporting.init` subscribes REGARDLESS of the preference (`if isOn { subscribe() }` →
     `subscribe()`); (M2) `CrashReportingPreference.remembered` reads `defaults.bool(forKey:)` (which
     takes "1"/"YES"/2 as yes); (M3) `CrashReporting.receive` drops its ON guard; (M4)
     `CrashReportCard` renders Send Report… whatever the bytes. Files:
     `Features/Diagnostics/CrashReporting.swift`, `Features/Settings/DiagnosticsPane.swift`.
     Restored with `git checkout --` on exactly those two paths. If a session dies mid-run, `git
     diff` against `f2d710b0` shows what is mutated; restore it.
     **THE MUTATION RUN — DONE, RESTORED (`git diff` empty after the checkout):** with the four
     mutants in, `Test run with 22 tests in 3 suites failed … with 19 issues` — **every mutant
     caught**: M1 (subscribe regardless) reddened `aFreshInstallIsOffAndRegistersNothing`,
     `launchAfterLaunchWhileOffNeverSubscribes`, `theAppsOwnerUsesMetricKitAndStartsOff` and the
     synthetic door's `offMeansNothingIsDeliveredEvenWhenAskedFor` (an OFF app suddenly had a
     subscriber to deliver into); M2 (`bool(forKey:)`) reddened
     `onlyAnExplicitYesIsOnAndEveryOtherValueRegistersNothing` across the strange values; M3 (no ON
     guard) reddened `aDeliveryWhileOnLandsVerbatimAndADeliveryAfterOffIsDropped`; M4 (Send
     whatever the bytes) reddened `aReportThatIsNotTextHasNoSend` (log `13r-u3b/mutants.log`).
     **Restored: `Test run with 22 tests in 3 suites passed`** (`restored.log`). No hollow pin
     found. Red-on-old by construction for the rest (the support draft, the Help door, the pane's
     place and search): none of it existed at `32b97fdc`.
   - **DEV-STORE WALK IN FLIGHT — THE RESTORE POINT, named before it runs (Debug build
     `App/Variorum/DerivedData/13r-u3b/dd/Build/Products/Debug/Variorum.app`, `io.lduarte.Variorum
     .debug`, the fenced dev store; `cliclick` + `Tools/WalkKit`, every step behind `guard.sh`; her
     app absent, idle ~56 min at the start; the host holds Accessibility + Screen Recording):** the
     dev domain's prefs EXPORTED to the gitignored
     `App/Variorum/DerivedData/13r-u3b/devprefs-prewalk/io.lduarte.Variorum.debug.plist` (the
     opt-in key ABSENT there); the dev container had NO `Application Support/Diagnostics` folder.
     **Restore at the walk's end (app quit):** `defaults import ~/Library/Containers/io.lduarte
     .Variorum.debug/Data/Library/Preferences/io.lduarte.Variorum.debug <that export>`; remove the
     walk's `Application Support/Diagnostics` folder and the synthetic file under the container's
     `Data/tmp/`; the voice back to Terminal (a dev-store synced setting); Mail was NOT running
     before the walk — the draft legs launch it, and it is quit again at the end (its compose
     windows closed UNSENT, Don't Save — nothing is ever sent).
     **THE DEV-STORE WALK — DONE, RESTORED (2026-10-04 ~21:53–22:06Z; every step behind
     `guard.sh`; captures in the gitignored `notes/plans/13r-screens/u3b/`):**
     - `w1/` — **Settings ▸ Diagnostics, a fresh state: the tenth pane in the list (stethoscope,
       between Data Safety and Acknowledgments), "Collect crash reports" OFF, the promise, the
       pointer, and "None. Nothing is collected while this is off."** (Terminal). The opt-in key read
       ABSENT in the dev domain before and at this capture.
       **WALK FIND, FIXED IN PLACE (`54d1ee4a`):** the first capture showed the pointer ending
       "Send Feedback…." — an ellipsis and a period stacked; the sentence now ends on the menu item
       ("…there's Help ▸ Send Feedback…"), rebuilt and re-captured before any later step.
     - `w2/` — **Settings search "crash"** → one result, "Collect crash reports", badged
       "diagnostics"; clicking it opens the pane.
     - `w3/` — **the toggle ON**: "None yet — that's the usual state."; the dev domain's
       `variorum.crashReports.optIn` read `1`.
     - `w4/` — **the INJECTED SYNTHETIC PAYLOAD through the seam:** app quit; a MetricKit-shaped
       crash report (marked SYNTHETIC in its `terminationReason`) written into the Debug container's
       `Data/tmp/`; relaunched with `open --env VARIORUM_SYNTHETIC_CRASH_REPORT=<it>` → the folder
       gained `crash-report-20261004T215907Z-03383b11.json` AT LAUNCH, **`cmp` byte-identical to the
       delivered file**; the pane lists ONE card — heading "Variorum 0.9.0 (4905) · macOS 27.0
       (26A428)" read out of it, "Received Oct 4, 2026 at 3:59 PM", the JSON VERBATIM in the bounded
       monospaced box (it scrolls on both axes; `w0-scrolled.png` shows the end of the report and the
       two doors, **Send Report…** in the accent, **Delete Report** quiet). Recorded honestly: the
       door's `NSLog` line did NOT surface in `log show` for the walk process (it does for the test
       host); the delivery is proven by the file born at launch, byte-identical, in a folder nothing
       else writes.
     - `w5/` — **Send Report… → MEASURED FINDING F-W5: this M3's Apple Mail has NO ACCOUNT.** Mail
       (not running before) launched and showed its own **Add Account** sheet; no compose window
       exists. The log shows the compose share extension (`com.apple.share.Mail.compose`) activated
       and **`sharingService:didShareItems:` — the service reported SUCCESS**, so the by-hand
       fallback never ran and Variorum could not tell. Cancel on Mail's sheet QUITS Mail; the draft
       is gone. **Nothing was sent** (there is no account to send from). This was the lookup's one
       UNCONFIRMED item; it is now measured. **Consequence for the acceptance: the draft-with-
       attachment cannot be SEEN on this machine** — its content and the attachment's identity are
       pinned headless (`SupportDraftTests`, incl. "what is sent is what was shown"), the road is
       proven to reach Mail's compose extension, and the on-screen draft is first seeable on her new
       computer's arm (f) if Mail is set up there (N-5 already carries the no-account branch).
       Routed: QUESTIONS #181 (i), options for her; `SupportMail.swift`'s header now says what was
       measured (no behaviour change).
     - `w6/help-menu-crop.png` — **Help ▸ … ▸ divider ▸ Send Feedback…** at the end of the Help
       menu. Pressed: Mail launched into the same Add Account sheet (`w6/w0.png`; the `mailto:`
       road, Mail the default handler — the URL is private to the system log); cancelled, Mail quit.
       Nothing sent.
     - `w7-study/` — **the card in the STUDY voice** (the serif room; the doors in the voice).
     - `w8/` — **the toggle OFF** (the Study layout moved the switch 11 pt up; the first click missed
       and was re-aimed from the capture, never blind): the key read `0`, **the received report
       STAYED** (OFF keeps what arrived — #181 (f)). `w8-general/` — the voice switched back to
       Terminal.
     - `w9/` — **OFF + the synthetic env on a fresh launch → NOTHING delivered:** the folder still
       held the one earlier report; the pane lists exactly it. An OFF app has no subscriber to
       deliver into.
     - `w10/` — **Delete Report** → the folder EMPTY, the pane back to "None. Nothing is collected
       while this is off."
     - **RESTORED:** app quit; the dev prefs re-imported, then the walk's one extra key
       (`variorum.crashReports.optIn`, which `defaults import` MERGES rather than removes) deleted —
       **the domain's export now equals the pre-walk export (diffed, equal)**; the walk's
       `Application Support/Diagnostics` folder and the synthetic file removed (neither existed
       before); the voice back to Terminal; Mail NOT running (as before — each leg's cancel quit
       it). Zero instances.
   - **SUITES (zero-instance window, Debug, `-derivedDataPath 13r-u3b/dd`):** U3-A's 22-suite family
     (registry walk, shell chrome, Open strip menu, chord legibility, update channel, entitlements,
     version scheme, What's New, calm asks, the sync faces incl. EncryptionFlow's, the iCloud offer,
     Settings shape, confirmations, status vocabulary, Data Safety's runbook, no-literal-colour, the
     two debug-oracle window suites, shell confirm, PostureSwitch) + appearance choice + the
     composition-road suite (`ProtectionSurfaceRenderTests`) + `OwnershipBadgeTests` (the catalog) +
     this unit's four: **`Test run with 272 tests in 31 suites` — 1 issue, the PRE-EXISTING 19e
     runbook drift, nothing else**; the `skipped:` lines are exactly the 7
     `DebugOracleSingletonWindowTests` tests + their suite (opt-in by design — U3-A's identical
     reading) (log `13r-u3b/close-suites.log`).
   - **A RELEASE COMPILE** (zero instances, `CODE_SIGNING_ALLOWED=NO`, its own
     `13r-u3b/release-compile.noindex`, never launched): BUILD SUCCEEDED; the binary carries **zero**
     `VARIORUM_SYNTHETIC_CRASH_REPORT` strings (the DEBUG-only door compiles out of what ships) and
     the opt-in key; it links only the SYSTEM `MetricKit.framework` (zero new dependency). The
     unsigned Release app — a REAL-store build if anyone launched it — was then REMOVED and its two
     LaunchServices registrations (the app + Sparkle's `Updater.app`) unregistered: 0 remain.
   - **SCOPE (`git diff --name-only 32b97fdc..HEAD`):** 14 Mac-target files under `App/Variorum/
     Variorum/` (`Features/Diagnostics/` ×5 new, `Features/Settings/` ×2 new + 2 edited, `Registry/`
     ×2, `EditorCommands`, `VariorumApp`, `VariorumAppDelegate`), 5 test files, `notes/QUESTIONS.md`
     (#181), this plan file. **No `Sources/`, `Shared/`, mobile or `Server/` path.** Commit count at
     the stop: 4907.
   - Build warnings: no warning in any file this unit created; the one warning in an edited file
     (`AppSettingsView.swift`, `PromoteTagsSheet`'s actor isolation) is pre-existing (U3-A's logs).

**U3-B STATE AT THE STOP (2026-10-04): ALL SEVEN PIECES DONE AND PUSHED; THE U3 WALK IS STAGED (piece
6), AUTHOR-GATED.** The orchestrator verifies by spot-check, then the pre-walk staging (N-0) begins.

---

## PHASE 13r — CLOSEOUT (2026-10-04, the orchestrator; the LIVE STATUS and unit records above are the evidence)

*[removed for publication]*

**THE RELEASES ARE LIVE: 0.9.0 (build 4911) and 0.9.1 (build 4913)** — notarized + stapled (4 Accepted submissions, 0 issues), byte-identical on `dl.stargazing.tech`, the two-entry appcast live with her notes verbatim and the edSignature verifying under the baked key, the no-cache header verified live for the first time, the page at 0.9.1; dSYMs durable per version. **THE FIRST EXTERNAL USER EXISTS** — her walk ran the whole road on a friend's computer (download → install → calm first open → the public-feed update), her verdict verbatim in the LIVE STATUS; the cadence day-counter arms declined at her word (their evidence: the U3-A dev-store walk + 15 CalmAsks pins + the 30-day simulated run).

**THE LADDER (two rounds, CLOSED):** round 1 — 0 BLOCKER · 0 MAJOR · 3 MINOR · 2 NIT; the cross-model exchange closed with ZERO DISPUTES (both implementers sharpened rather than disputed); all five findings fixed at the reviewer's hands (F3 pin-first red-on-old + revert-verified; F1's immutability rider MEASURED 200/404; F2's by-construction key; the F4 refinement accepted from the sanity pass's NIT and verified against Sparkle's source) + the pre-existing VersionSchemeTests literal repaired to R-13r-6's ruled shape. Round 2 (FRESH reviewer) — 0/0/0/3, every fix SOUND, no round 3; the three NITs dispositioned record-only. **FINALS:** 274/31 (exactly the one named pre-existing red — 19e, queued) · 166/34 · 2/2 · core 2174/244 (the 19a baseline exact) · the round-2 re-run 45/5. **Zero `Sync/`, zero schema, zero custody lines in the whole phase; the marker stays 12.** KnownIssues row 24 RESOLVED on the U1 drill's PASS. New process rulings this phase: R-13r-15 (the site-publish exemption), R-13r-16 (the combined public-road walk); release lessons recorded (no commits mid-release-run; the cache-busted preflight; the negative-cache purge road).

**DEFERRED/CARRIED:** U4 (post-🚀, the brief intact); 19e (the runbook doc drift, queued — the ledger UN-PARKS at this close); the §12 calm-asks contract line PROPOSED in the handoff (lands only at her word); QUESTIONS #180/#181 her ratify bundle; the site runbook's bucket-side preflight proposal; the field-guide re-seed press (hers, one click, in the handoff); N2's back-to-back HEAD comparison at the next release; N3's message fold at the 1.0.0 scheme event. **MOBILE PARITY:** the calm out-of-date sync sentence REACHES THE PHONE (the face is `Shared/`; no door — its updates are the App Store's); the phone's crash-report opt-in face and the phone's What's New (the App Store road) are named candidate rows — all three carried to `notes/MobileSoul.md`'s ledger. **The author handoff is `notes/handoffs/phase-13r-handoff.md` — her checklist IS the friends-beta checklist.** 17y runs next at her kickoff (its message at the 17y entry's tail); the 19 ledger is active again.

*[removed for publication]*
