# Phase 14a — author handoff (closed 2026-08-04)

## Your checklist

1. **Change your bootstrap password** at `https://stargazing.tech/oauth/reset`
   whenever convenient. The one set at round 0p is transcript-known by your
   choice; the deployed reset page serves real resets now. (Your 14b
   encryption passphrase will be a separate, stronger secret regardless —
   the standing wrap-secret ruling.)
2. **Open 14b at your word:** paste the kickoff message from
   `notes/plans/phase-14b-suite-e2ee.md`. It opens with YOUR design sitting —
   the five pinned questions (phone-first device enrollment ·
   Fragments-insights-vs-journal-E2EE · wipe-and-repush vs in-place mirror
   migration · the KDF/recovery/enrollment one-way doors · the vault-home
   free re-open). Cast decided there; your recorded lean is all-Fable.
3. **Nothing to carry to Fragments yet.** The ONE batched handoff (all three
   touchpoints) executes at 14c's end, per your own ruling.
   `notes/fragments-bridge-contract.md` is the brief you'll carry;
   touchpoint #1's coordinates are already delivered in it, and the client
   secret sits in your untracked `.env.fragments-oauth.local`. Until that
   batch: Fragments' old issuer stays ON (harmless; nothing uses it), and
   the bridge stays idle under your pause.
4. **Your phone:** the next mobile session/install carries the new sign-in
   automatically (shared seam) — verify signing in end-to-end there once,
   then PL-5 closes. The mobile parity round's Stage A is now UNBLOCKED
   (its trigger was exactly this landing).
5. **Your pause** (all Variorum activity until Phase 14 completes) is yours
   to keep — nothing in 14a ended it; 14b's mirror migration is exactly
   what it protects.
6. Optional, anytime: the sign-in refusal wording you ratified at the gate
   ("Wrong email or password.") is one line to change if you ever want
   different text (`ErrorPresentation.signInFailureMessage`).

## What shipped, and why it's shaped this way

**One login, homed where you ruled it.** The Variorum project itself is the
suite's account home and OAuth 2.1 issuer (your round-0h flip — taken on
five new facts after three of your own challenges; the separate-project
ruling of 0c is superseded, recorded, never erased). "stargazing" is the
BRAND: the sign-in/consent/sign-up/reset pages live at stargazing.tech and
talk to the Variorum project's API; a custom domain fronts the issuer
before any stranger ever signs up (pinned on the 14c row, refined to
before-the-Fragments-handoff so provider configs are written once).

*[removed for publication]*
on every row of your corpus, untouched by construction — now signs in with
a direct email+password. The `custom:fragments` proof is retired
END-TO-END: out of the app's code (batch 1), your identity row deleted, the
provider config deleted (the gate — each act announced, run by your own
hand where the permission layer wanted it, verified before/after; your user
now has ZERO identity rows, which is safe because password sign-in provably
never consulted identities — the 0p test, re-proven by your live sign-in).
The 9c trust arrow no longer exists in either direction.

**The app's sign-in is the form you used at the gate** — Mac and mobile
through ONE shared seam (`AccountView`/`AuthSession`; the mobile→main merge
preceded the batch precisely so this would be one door, not two). The
browser/PKCE machinery (SignInFlow) is deleted, not mothballed — it returns
at the Fragments batch built against the live provider, per your 0x cut of
the premature dormant road. The bridge's machinery is byte-untouched and
idle under your pause; its session goes suite-delegated at the batch era,
when the two-form Account surface collapses into your one sign-in (your 0i
ruling, timed by your 0t one-batch ruling).

**The 14b vault is confirmed viable as ruled** — the spike's P-ii probe
(flagged unverified since 9c) proved an OAuth-server-issued token is an
ordinary authenticated PostgREST user on this project, so RLS'd vault
tables on plain `auth.uid()` work; the 14c entitlement reads the same way.
The signup door re-probed REFUSING (422) with the OAuth server live — the
signups-off toggle remains the corpus's sole guard until 14c, exactly per
your 0j word.

## Counts and verification

- **Final: core 1039/114 · Mac 1196/208 (the one red = the standing
  TakePane tripwire, BY IDENTITY) · mobile 172/24 · spine 51/7.** Core is
  provably untouched since its run (empty `Sources/`/`Tests/` diff across
  every post-batch commit). Zero `Sync/` lines phase-wide; NO schema
  (lockstep marker stays 4); no AppSpec §14 delta (SyncSpec §2 carries the
  dated annotation).
- **The ladder** (full record in the plan file): round 1 — no BLOCKER/MAJOR;
  3 MINOR + 2 NIT, all fixed with the R1-1 pin revert-verified both
  directions. Round 2 — every disposition HOLDS under a fresh reviewer's
  own re-derivation; zero new HIGH; ladder closed. The substantive catches:
  the wrong-password refusal now speaks ("Wrong email or password." — was a
  raw Swift enum dump), and the iPhone sign-in sheet is no longer clipped
  by a Mac-era `minWidth` (that fix is why your phone door will look right
  at step 4 above).
- **No open PROVISIONALs from this phase.** The one PROVISIONAL (the
  refusal wording) you ratified at the gate. The brand ("stargazing")
  remains provisional by your standing word — not a 14a artifact.

## For the mobile project (the round-0m update, self-contained)

The shared auth seam changed at 14a: `SignInFlow`/`custom:fragments` are
gone; sign-in is a direct email+password form in the shared `AccountView`
(reached via Settings → the sync row's sheet), driving
`AppServices.signInWithVariorum` → `AuthSession.signInWithPassword` against
the Variorum project (`ProjectConfig` carries the coordinates). The iPhone
fixes are already in: the 440pt `minWidth` is macOS-gated, and the
credential fields carry `.textContentType(.username/.password)` for
AutoFill. Mobile suite ran 172/24 green at the closeout. What the next
mobile session owes: one live end-to-end sign-in on the phone (PL-5), then
Stage A of the parity round at her word.

## Where everything lives

- The phase record (rulings 0d–0z, ladder, gate, ledger L1–L13):
  `notes/plans/phase-14a-suite-identity.md`.
- The 14b kickoff draft + pinned sitting questions:
  `notes/plans/phase-14b-suite-e2ee.md`.
- The Fragments one-batch brief: `notes/fragments-bridge-contract.md`
  (READ-THIS-FIRST pointer → EXECUTION MODEL → touchpoints #1–#3).
- The pages brief the site agent built from:
  `notes/stargazing-login-pages-brief.md`.
- 14c's scope ledger: the master plan's 14c row (one-batch handoff,
  custom-domain timing, SMTP, account deletion, `setting` redesign,
  isolation, the tier).
