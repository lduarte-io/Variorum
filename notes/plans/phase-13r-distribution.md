# Phase 13r — Distribution Mechanics (the Sparkle round)

**STATUS: OPEN — opened 2026-09-25 at the author-attended kickoff sitting (this file's SITTING
RECORD is the binding record of its rulings). Units not yet started. LIVE STATUS at the bottom.**

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
in the Keychain and her password manager ONLY.

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

## LIVE STATUS

- **U1 — NOT STARTED.** Opens with HER HANDS steps 1–2.
- **U2 — NOT STARTED** (gated on U1; her step 3 at its start).
- **U3 — NOT STARTED.**
- **U4 — NOT STARTED.**
- Ladder / closeout — not started.
