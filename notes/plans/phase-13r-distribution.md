# Phase 13r — Distribution Mechanics (the Sparkle round)

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
stamping too); memory updated. Marker stays 9; zero `Sync/` expected — any `Sync/` line stops for
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
  fast user switching in the Menu Bar) — steps given; her account name lands here when she
  reports it.
- **U3 — NOT STARTED.**
- **U4 — NOT STARTED.**
- Ladder / closeout — not started.

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
