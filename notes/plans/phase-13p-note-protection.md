# Phase 13p — Note Protection: Whole-Store Encryption

*(Title until 2026-08-27: "… & Locked Notes". The locked-notes half was
DROPPED at the kickoff sitting — R13p-16 below: per-note locks are not
built, probably ever.)*

**STATUS: OPEN — kicked off 2026-08-27 via `/architect-phase 13p`.**
**Cast (her call, in the kickoff message): Fable architect/orchestrator ·
Opus implementers (fresh session per batch) · ONE Fable cold review at
phase end.** Any `Sources/VariorumCore/Sync/` line that proves necessary
routes to Fable under the standing rider (Batch 1 expects zero). The RUN
RECORD section at the bottom of this file is the running ledger.

*(Original banner, for the record: plan AUTHORED 2026-08-24, out-of-band —
written at the author's direct instruction at the close of her 2026-08-23/24
encryption design conversation, an author-attended Fable session run while
Phase 13l executed in a parallel session.)*

---

## KICKOFF MESSAGE (for the fresh session that runs this phase)

Read, in order: this file top to bottom (it is self-contained); `CLAUDE.md`
and the canon docs per the standing preflight; `notes/SyncSpec.md` §12 (this
phase carries ONE lockstep event — **SUPERSEDED at the kickoff sitting,
R13p-16: the phase now carries NO lockstep event; the marker stays 7**);
`notes/MobileSoul.md` (this phase is a
both-platform phase by construction — mobile's deliverable is named INSIDE
it, §6's "design together" class); `notes/plans/note-protection-design-note.md`
**as history** — its shapes A/B framing is SUPERSEDED by this plan's
constitution (the note's own tail says so); `notes/plans/phase-13l-data-safety-floor.md`'s
closeout (13l built the backup/restore drill this phase upgrades and the
passphrase sanity-check face Batch 2 composes with — and the app lock did
NOT ship there: it moved HERE unbuilt, R13p-14 — read what actually
shipped, not what was planned).

**What changed vs. the master plan's 13p row:** the row's BODY (and the
design note) describe a shape-A→shape-B destination. The author's
2026-08-23/24 conversation RULED a different destination — whole-store
encryption as the substrate, per-note locks as access-gate faces, shape B
retired to a named non-goal. The row now carries a **POINTER RIDER**
(added 2026-08-24, mid-13l, alongside the app-lock move) saying exactly
that and "Read the PLAN, not this row"; the row's old body text was
deliberately left standing under it. **This kickoff's first act is the
full reconciliation of the 13p row to this plan** — replace the stale
body, keep the rider's spirit (this file stays the binding record).

First acts, in order: (1) reconcile the master-plan row as above;
(2) verify the starting state (suites green at the then-current closeout
baseline — re-baseline from the latest closeout, NOT this file's numbers;
lockstep marker at 7; `grep -rn "mmap" Sources App` still empty);
(3) hold the kickoff sitting on the OPEN KNOTS section below — everything
else is ruled and is not re-opened; (4) run Batch 0, the spike, and write
its decision memo before any committed build work.

Standing author-only calls bind as always: the lockstep deploy window is
hers (the 13j precedent — her hands on the trigger), Keychain/TCC prompts
are hers, and the SQLCipher dependency is ALREADY APPROVED (see the
constitution, R13p-11) — do not re-litigate it, and do not add any OTHER
dependency without her.

---

## THE CONSTITUTION (author rulings, 2026-08-23/24 — binding on all 13p work)

Recorded verbatim-faithful from the conversation. These are ruled, not
provisional; the kickoff sitting rules only the OPEN KNOTS section.

- **R13p-1 — The destination is whole-store encryption, layered.** The
  store is encrypted at rest as one unit (SQLCipher via GRDB); per-note
  locks ride on top as access gates. Her derivation, verbatim: *"why not
  just encrypt the whole thing so all access is in memory and you can
  demand unlocking every time."* And the identity ruling: *"I think I'm
  realizing that true encryption and privacy IS the story I want … it makes
  journaling genuinely feel safe — which is what I want for myself."*
  *(The "per-note locks ride on top" HALF is SUPERSEDED at the 2026-08-27
  kickoff sitting — R13p-16: per-note locks are dropped. The whole-store
  half stands untouched and is the phase.)*
- **R13p-2 — Universal, never optional.** *"I agree the encryption should
  be universal - no real point in making it optional."* Every store is
  encrypted; the dials are custody and ceremony, never whether.
- **R13p-3 — Shape B (column-level sealing) is RETIRED to a named
  non-goal.** *"I don't think that we need shape B column sealing - this is
  already sounding very very very secure."* The one threat it declines is
  recorded honestly below (non-goals).
- **R13p-4 — One secret, ever.** The store key is a random 256-bit key,
  SEPARATE from the sync master key, wrapped by the SAME encryption
  passphrase and the SAME BIP-39 recovery phrase as 14b's vault. No second
  passphrase exists anywhere in the design.
- **R13p-5 — Three at-open modes, as a setting**: **Auto** (Keychain
  releases the key silently), **Biometric** (`.biometryCurrentSet`-gated
  Keychain item — the login password can NOT release it; fallback is the
  PASSPHRASE, never the device password), **Passphrase-every-open**. Her
  *[removed for publication]*
  someone who knows their computer password but might not know their
  passphrase"* — so the login password is NEVER in the privacy modes'
  chain. Her biometric-reliability worry (*"sometimes faceid and touchid
  can just stop working"*) is answered by the passphrase fallback, not by
  the device password.
- **R13p-6 — iCloud Keychain escrow is a dial.** A SEPARATE synchronizable
  Keychain item carries a wrapped key copy (it cannot be the biometric-
  gated item — Apple does not sync access-controlled items). ON in the
  Standard preset, OFF in Locked-down. The setting's wording states the
  trust honestly in one sentence each way.
- **R13p-7 — Two presets, dials underneath**: **Standard** (auto open,
  escrow on, recovery phrase generated and nudged) and **Locked-down**
  (biometric or passphrase at open, re-lock policy, escrow off, reminder
  checks on). Her framing: *"the settings should be easy for the normies
  but for the truly privacy conscious (say, a journalist or someone with a
  really sensitive personal diary), the app should have settings that let
  you go to the more extreme end yourself."* Presets are dial-setters;
  every dial stays individually adjustable.
- **R13p-8 — Exactly ONE deliberate plaintext escape**: the bulk-`.md`
  export (13l's candidate). Never a plaintext copy of the sqlite file. A
  SCHEDULED plaintext export under Locked-down warns that it re-opens the
  door the encryption closed. (Grown from her *"allowing a non encrypted
  backup to be made … could also be an option"* + the adopted
  one-escape rule.)
  **RIDER (author ruling, 2026-08-24 at the post-13l polish round's
  #75 sitting — verbatim):** *"the automatic plaintext backup is
  going to be ended 13p, when encryption is added, since it weakens
  encryption. i think it can still be available to users that want
  it, but it should be off by default once encryption is present."*
  So: the 13l weekly `.md` insurance runs as shipped UNTIL this
  phase; the moment encryption is present, the AUTOMATIC export
  flips **OFF by default**, surviving as an opt-in for users who
  want it (composing with this rider's own warn-under-Locked-down
  sentence). The 13l unit was built grep-able for exactly this
  moment (`MarkdownInsurance`).
- **R13p-9 — Reminder checks + the reset door.** Periodic, dismissible
  "do you still remember your passphrase?" checks (her ask, the 1Password
  pattern), and the forgot-passphrase RESET door: any enrolled device
  re-wraps the key under a new passphrase after biometric confirmation —
  no old passphrase needed (the envelope's whole point). Loss is real only
  when every enrolled device AND the passphrase AND the recovery phrase
  AND the escrow copy (if on) are simultaneously gone.
- **R13p-10 — Search's display rule.** The index may CONTAIN everything
  (it is exactly as encrypted as the content); a locked note's hits
  DISPLAY as existence-without-content ("1 result in a locked note",
  no snippet), full hits after unlock. This is handed to 13o as a ruled
  input — 13o's old "index must never contain" constraint is dissolved
  by construction. Her words: *"it makes search / indexing better, it
  lessens the technical burden of 'individually locked notes'."*
  *(DISSOLVED at the 2026-08-27 kickoff sitting — R13p-16: with per-note
  locks dropped there is nothing to gate. The ruled input to 13o
  simplifies further: the index may contain AND DISPLAY everything — the
  store itself is the protection. The "lessens the technical burden"
  motivation survives by removing the burden entirely.)*
- **R13p-11 — The dependency is APPROVED (2026-08-24, her words: "I
  approve the license and the approach - I'm glad to know that this is
  all available and free").** SQLCipher **Community Edition** (BSD-style,
  Zetetic LLC), integrated as: a four-line **fork of groue/GRDB.swift**
  (the README-documented GRDB+SQLCipher uncomment road) pulling Zetetic's
  OFFICIAL SPM package **`sqlcipher/SQLCipher.swift`** (prebuilt
  XCFramework, ≥ 4.18.0), with `SQLITE_HAS_CODEC` defined in the
  consuming targets. The attribution obligation ships with the phase: an
  acknowledgments surface carrying the Zetetic copyright line, the license
  text, and dependency notices. REJECTED roads, so nobody re-walks them:
  the DuckDuckGo fork (stale — frozen at GRDB 7.4.1, no commits since
  2025-03) and CocoaPods (GRDB publishing frozen at 6.24.1).
- **R13p-12 — Positioning: the trust floor, not the headline.** The
  identity stays "the writing app with takes"; encryption is the substrate
  stated in one calm sentence. It completes the AI story her 13n row
  carries — her words: *"true 'only the writing you expose goes to AI' is
  only available with this option"* — and the competitive claim is
  citable: Day One's own FAQ says "The Day One local database is not
  encrypted"; Bear and Apple Notes are per-note; Obsidian is plaintext by
  design. No mainstream writing comparable encrypts the whole local store.
- **R13p-13 — Passkey-PRF: declined knowingly.** Available (macOS 15/iOS
  18+, works with synced platform passkeys, the Bitwarden vault pattern),
  but the plain synced Keychain item achieves the same escrow with less
  machinery. Recorded as a credible future alternative, not built.
- **R13p-14 — THE APP LOCK ARRIVES HERE, BORN REAL (author, 2026-08-24,
  at the 13l sitting — added by the 13l architect executing her ruling;
  her 13p planning agent reviews and tweaks).** Her words: *"honestly,
  maybe the lock should just be moved into 13p's plan. it was always an
  add on to 13l"* and, agreeing to the move: *"I agree, and we don't
  need system password allowed anymore - we have a better story and a
  more cohesive approach now."* Consequences: (a) 13l ships NO app lock
  and NO interim "adds no encryption" caveat — the first lock a user
  ever meets is R13p-5's at-open gate, backed by real key custody;
  (b) **her 2026-08-23 13l ruling (fallback as a user setting with the
  system login password allowed) is RETIRED** — R13p-5's chain (the
  login password NEVER in it; the passphrase is the fallback) stands
  as THE story, unconditionally; (c) the ONE gate is the at-open mode —
  no separate app-lock feature exists to stack in front of it (the
  Standard preset's Auto mode is the no-gate default, playing the old
  "lock off by default" role); (d) the mobile Face ID twin ships inside
  Batch 4 as already planned. The 13l passphrase/recovery SANITY CHECK
  stays in 13l (her same message) — independent machinery, live
  forget-risk today.
- **R13p-15 — A BATCH-1 DECISION FLAGGED FROM 13l (the 13l architect,
  2026-08-24 — surfaced by the author's own question about the regret
  road under encryption): THE PLAINTEXT BACKUP RETENTION TAIL.** 13l
  ships a second backup destination with ~6 weeks of retention (14
  dailies + 4 weeklies, her picked folder — likely iCloud-synced).
  When 13p's migration encrypts the store and `backup(to:)` starts
  writing ciphertext, **the pre-13p PLAINTEXT backups keep sitting in
  BOTH destinations until rotation expires them — up to ~6 weeks of
  readable prose outliving the encryption flip**, and longer under
  Time Machine/external snapshots (outside our retention entirely).
  Batch 1 / the kickoff decides: age-out-with-disclosure (13l's M6
  framing already generalizes — "older backups are plaintext until
  rotation") vs a deliberate rotate/delete-old-backups offer at
  migration. The zero-plaintext acceptance pins the FRESH backup
  either way; this decision is about the TAIL. **RULED — same
  night, 2026-08-24 (author, verbatim): "im the only user right now
  so just record that the aging out is fine."** Age-out-with-
  disclosure it is: no rotation machinery; the disclosure sentence
  (13l's M6 generalization — "older backups are plaintext until
  rotation") ships in the migration's honest copy. *(If real
  strangers exist by 13p's run, the kickoff may glance at this once
  — her ruling was expressly made as the only user — but nothing is
  owed beyond the disclosure.)*
- **R13p-16 — PER-NOTE LOCKS ARE DROPPED: BATCH 3 IS NOT BUILT, PROBABLY
  EVER (author, 2026-08-27 at the kickoff sitting — ruled on her own
  challenge to the layering).** Her words, verbatim: *"ok, we will not
  add the per lock note - it's easy enough to add faceid or biometric to
  opening the app (with a passphrase, not computer password) as the
  backup. I plan on exposing all the apps on the appstore that offer
  'lock' on opening their journals but are not actually encrypted as
  part of my advertising for my app, so it would be bad if I added the
  same security theater that they use. So I don't think we need to build
  batch 3 at all, probably ever, because it makes users think privacy is
  in place that just isn't."* The mechanism, traced at the sitting:
  inside an already-unlocked app the store key is resident and the whole
  database readable through the open connection, so a per-note gate is a
  UI CURTAIN — real against the casual snoop, theater against anyone
  serious. (Apple Notes' per-note lock is real precisely because it is
  per-note CRYPTO — shape B, retired at R13p-3; given that retirement,
  the curtain kind was the only buildable kind, and the honesty doctrine
  cuts against it.) Her advertising angle makes shipping it actively
  anti-brand. Consequences: **(a)** R13p-1's "per-note locks ride on
  top" half is superseded — the at-open modes (R13p-5) + re-lock/Lock
  Now ARE the whole gate story; **(b)** R13p-10's display rule dissolves
  — search indexes AND displays everything; **(c)** Batch 3 dissolves
  whole: NO `v1_15`, NO §12 lockstep event anywhere in this phase, the
  marker STAYS 7 (13y's event becomes the next one), no mirror DDL, no
  deploy window; **(d)** open knots 1, 2, 5, and 7 dissolve (no flag
  semantics; no bridge asymmetry — the bridge is untouched; no
  inside-or-after; no snippet gate — 13u's brain needs no protection
  awareness); **(e)** the 13n corner closes by HER correction, not by a
  flag — grants are allowlist-shaped (*"the AI grant will be based on
  granting particular notes, not \*not granting\* locked notes"*), so
  nothing needs a lock flag to stay unexposed; **(f)** Batch 4's mobile
  deliverable narrows to the at-open/lobby/settings faces; **(g)** the
  phase-wide expectation hardens: ZERO schema, ZERO lockstep, and
  (per Batch 1) zero `Sync/` lines expected. Per-note locks join the
  NON-GOALS so the decline stays named.

## A RIDER FROM 13l (2026-08-24, her disposition at QUESTIONS #78)

The bridge's restage/sentinel seam: when this phase rebuilds re-key
machinery, adopt **shape (b)** — `stageRepushFromTruth` stops stamping
its sentinel onto `bridge_day` rows whose note is already dead, so
their last agreement survives and their deletions still travel
VERIFIED. Her words: *"we don't have to solve this right now …
whatever you think is best could probably ride along then."* No
Fragments-side change is needed; the stranded-days status note (13l's
fix) then covers only the historical population, which is zero on her
store today. QUESTIONS #78 has the full shape menu.

## AUTHOR ADDITIONS (2026-08-25, the launch-strategy conversation)

- **TWO OUTBOUND BRIEFS ARE PHASE DELIVERABLES (her instruction,
  verbatim):** *"the phase for encryption needs to both write a brief
  for the fragments agent and update the brief for the stargazing.tech
  agent's privacy policy."* (a) A dated brief for the FRAGMENTS agent
  via `notes/fragments-bridge-contract.md` (the standing carry channel
  — she carries it): what Variorum's whole-store encryption means for
  the suite's privacy story, and what — if anything — Fragments wants
  for its own at-rest story. Standing facts the brief starts from: the
  bridge's JOURNAL class is E2EE and live since 14d; the REST of
  Fragments is server-readable BY DESIGN (the 14b ruling — its insights
  are the product); whether Fragments adopts a 13p-style local store
  encryption is that app's call, informed by this brief. Her stated
  goal: finishing this encryption *"lets me finish fragments and have
  a cohesive privacy policy."* (b) An UPDATE to the stargazing.tech
  agent's privacy-policy brief so the policy states the whole-suite
  story cohesively (what is E2EE, what is local-encrypted, what is
  server-readable and why).
- **Her backup/portability questions, answered where this plan already
  does:** *"are we exposing the SQLite backup toggle?"* — 13l shipped
  the user-facing Data Safety surface (destination picker, Back Up
  Now, freshness face); this phase keeps it and RE-KEYS it (backups
  become ciphertext — the research-record #10 trap). *"can we add in
  addition to the plaintext save elsewhere a SQLite save in a
  different folder?"* — the second-destination SQLite backup IS 13l's
  shipped shape (14 dailies + 4 weeklies to her picked folder); under
  this phase those copies become ciphertext, and the plaintext escape
  narrows to the opt-in `.md` export per R13p-8's rider. *"how will
  this work once encryption is present?"* — THE DESIGN's backup
  paragraph + R13p-15's ruled age-out tail.
- **OPEN KNOT 10 — the AirDrop / no-sync migration story (her
  question, verbatim: "can someone airdrop their work to a new
  computer, even if they don't want to pay for sync").** The substrate
  says yes — rows-as-truth, one file; `openStore(at:)` is keyed in
  Batch 1; the restore drill already proves the new-machine key leg
  (passphrase / recovery phrase / escrow). What the sitting decides:
  whether a deliberate user-facing "move your library" door ships in
  this phase or is handed to 13r's distribution checklist, and the
  sync-state hygiene of a moved store — a copied store carries
  `sync_state.device_id`, so an adoption door should consider
  resetting device identity so a later subscription on the new machine
  never shares the old device's cursor. She intends to MARKET this
  ("airdrop your corpus to your new computer and it will work" is in
  her launch-video list), so the claim should be true by a built door,
  not by luck. **RESOLVED IN HOME, 2026-08-25 (her word, same
  sitting): the door is PHASE 13X's** — a new pre-launch row created
  at the sitting (*"it could be 13x I think, and should come in
  before launch because it's a real promise"*). This phase still
  delivers everything 13x rides on — the keyed `openStore(at:)`, the
  ciphertext backups, and the drill-proven new-machine key legs — and
  the knot collapses to: hand the adoption-door and device-identity
  details to 13x's design.

## NON-GOALS (named so they stay declined, not forgotten)

- **Per-note locks (the former Batch 3 face) — DROPPED at the kickoff
  sitting, probably permanently (R13p-16).** Inside an unlocked app they
  are a curtain, not a boundary; shipping one would mirror the
  lock-on-open theater her advertising exposes ("it makes users think
  privacy is in place that just isn't"). If ever revisited, it re-opens
  as a DESIGN question weighed against shape B's costs — never as a
  quiet flag.
- **Shape B column sealing.** The one threat it covers that this design
  does not: an attacker holding the app OPEN and UNLOCKED, reading notes
  whose per-note gates would have kept their plaintext out of reachable
  memory. Named honestly in any security copy; not built.
- **13o search itself.** This phase hands 13o the display rule (R13p-10)
  and the FTS5 answer (spike Q1); it does not build search.
- **Export-compliance paperwork.** Shipping our own crypto means
  `ITSAppUsesNonExemptEncryption = YES`, likely a French (ANSSI) import
  declaration for France distribution and a one-time US BIS
  self-classification under License Exception ENC. Standard-AES middle
  tier — forms, not approvals. **Owned by 13r's distribution checklist**;
  verified against the App Store Connect wizard at submission time.
- **Key/credential rotation at scale** — stays on the v1 release
  readiness row.
- **13n's grant grammar** — ~~13p only guarantees the protection flag is
  readable so 13n can exclude protected notes by default~~ *(superseded
  at the kickoff — R13p-16(e): no flag exists, and none is needed; her
  correction: grants are allowlist-shaped — "granting particular notes,
  not not-granting locked notes" — so nothing is exposed until granted).*

## THE PRE-PHASE RESEARCH RECORD (2026-08-24 — what is already settled as fact)

A Sonnet research pass (author-commissioned, citations in the session
record) plus direct repo checks established, so the phase does not
re-derive:

1. **The integration road** is R13p-11's, and it is the CURRENT documented
   road *(SPIKE CORRECTION #1, memo Q4: the recipe is SIX sites across
   three kinds of edit — four uncomments AND three deletions of the
   `GRDBSQLite` product/target/dependency; "four-line uncomment" was the
   plan's own shortening. And CORRECTION #2: `SQLITE_HAS_CODEC` is NOT
   needed on consuming targets — tested both ways; the repo change is a
   ONE-LINE dependency swap)*: GRDB's master README + `Package.swift`
   carry the exact fork-and-uncomment recipe pointing at
   `sqlcipher/SQLCipher.swift`
   (actively maintained by Zetetic, same-day releases with SQLCipher core;
   4.18.0 current). GRDB ≥ 7.9 renamed its codec flag to
   `SQLITE_HAS_CODEC`, making the pieces flag-compatible; baseline Swift
   6.1+/Xcode 16.3+ — cleared by our 6.2/Xcode 26. The fork's only delta
   is the uncomment; GRDB's maintainer attributes the fork requirement to
   Xcode's missing package-traits support, i.e. it has an expiration date.
2. **License**: Community Edition permits closed-source commercial use,
   free; obligations are attribution only (copyright line + license text +
   dependency notices, user-accessible). Paid editions add nothing we need.
3. **Keying**: the raw-key form (`x'…'`, 64 hex chars) BYPASSES the KDF
   entirely — ordinary open pays zero derivation cost. Passphrase keying
   at the SQLCipher layer (256,000 PBKDF2-HMAC-SHA512 iterations) is the
   road we deliberately do not take; Argon2id runs only in OUR envelope,
   on the rare unwrap-by-passphrase road.
4. **mmap is a non-issue, verified BOTH ends**: SQLite's default
   `mmap_size` is 0 (disabled); GRDB's `Configuration` has no mmap knob at
   all; and `grep -rn "mmap" Sources App` in THIS repo returns nothing
   (checked 2026-08-24). Nothing is lost that was never on.
5. **Memory at scale is bounded**: the page cache is a fixed pool
   (`PRAGMA cache_size` semantics), independent of database size. No
   "by-the-area loader" is needed — P1/P3 + indexed reads already are one.
   Expected overhead 5–15% (Zetetic's own figure), page decrypt is
   hardware AES.
6. **WAL is supported** (WAL pages encrypt under the same key).
   **`secure_delete` is ON by default in SQLCipher** — freed pages are
   overwritten (slower bulk deletes; a real synergy with 13j's "really
   deleted" story). Keep-or-tune is an open knot, decided on the spike's
   measurement.
7. **`sqlcipher_export()`** is the documented one-time re-encrypt road
   (attach empty keyed DB → export → swap), in GRDB's own README.
8. **FTS5 is NOT confirmed present in Zetetic's prebuilt binary** (it
   requires an explicit build flag; the prebuilt's flags are not
   published). Spike question #1. **ANSWERED, memo Q1: PRESENT** —
   `ENABLE_FTS5` in the binary's own compile_options AND exercised
   end-to-end (virtual table, MATCH, `snippet()`, `rank`, GRDB's typed
   `FTS5()` API) against a genuinely encrypted store. 13o is unblocked;
   the contingency ladder is moot.
9. **Apple platform facts, confirmed with citations**: biometric-gated
   Keychain items are ThisDeviceOnly by construction and cannot sync (the
   escrow item is necessarily separate — already the design);
   `.deviceOwnerAuthenticationWithBiometrics` excludes the password
   fallback (any fallback is the app's own — ours is the passphrase);
   iCloud Keychain is E2EE with HSM-gated escrow (10 attempts, then the
   record is destroyed).
10. **The repo trap found by reading (2026-08-24)**:
   `AppDatabase.backup(to:)` (`Sources/VariorumCore/Persistence/AppDatabase.swift`)
   opens its destination as a bare `DatabaseQueue(path:)` — the SQLite
   backup API writes through the destination's pager, so under SQLCipher
   an UNKEYED destination produces a PLAINTEXT backup silently. Batch 1
   keys the destination and pins it (see the batch). **SPIKE CORRECTION
   #3 (memo Q5) — the trap is REAL but NOT this shape:** SQLCipher
   REFUSES `sqlite3_backup` on a key mismatch (*"backup is not supported
   with encrypted databases"* — a LOUD throw, no silent leak), while a
   KEYED destination succeeds, yields ciphertext, and round-trips. So
   the danger is not leakage but BREAKAGE: `backup(to:)` — and with it
   13l's entire backup machinery — STOPS WORKING the moment the store is
   keyed. The Batch 1 riders below carry the one-commit rule and the
   corrected pin shape.

## THE DESIGN (technical shape — what the batches build)

**Key architecture.** One random 256-bit store key per store, minted at
migration (existing stores) or first launch (new stores). Wrapped copies:
(a) passphrase-wrapped (Argon2id — the 14b machinery, reused);
(b) recovery-phrase-wrapped (BIP-39 — reused); (c) the device Keychain
item — accessibility/ACL set by the at-open mode (Auto: WhenUnlocked-class,
no user presence; Biometric: `.biometryCurrentSet`); (d) the OPTIONAL
escrow item — synchronizable, NO access control, per R13p-6. Passphrase
change = re-wrap only, never re-encrypt. The store key is deliberately NOT
the sync master key (R13p-4): local-only signed-out users have a store key
with no account, and sync enrollment composes beside it.

**The keyed stack.** `AppDatabase.configuration()` gains the keying step
(GRDB `prepareDatabase` issuing the raw-key `PRAGMA key = "x'…'"` on every
connection — pool writers AND readers). In-memory test stores are
unaffected (the test factory stays byte-identical; suites prove it). The
locked-lobby launch state: in the demanded modes NOTHING runs before
unlock — no migrations, no sync round, no bridge round, no purge janitor;
they all start after the stack exists. Re-lock (Locked-down dial): tear
down observations, close the pool, drop key material; reopening rebuilds
the stack through the composition root (this teardown/rebuild is real
engineering and gets its own tests — ValueObservation lifecycles must not
outlive the pool). A **manual Lock Now act** (menu item + keybind; the
phone twin) exists in the DEMANDED modes only — under Auto it would be
theater (the key auto-releases at the next open), and R13p-14's whole
point is that no theater ships.

**The one-time migration** (existing stores): export-to-temp via
`sqlcipher_export()` into a KEYED destination → verify the temp opens and
row-counts match → atomic swap → remove old db + `-wal`/`-shm`. Crash-safe
at every step (a crash mid-road relaunches into either the old plaintext
store or the verified new one, never neither — the 14c re-run-guard
discipline). Honest footnote, recorded not hidden: SSD free-space remnants
of the old plaintext file are unrecoverable-in-practice under FileVault;
we do not claim secure erasure of the pre-migration file.

**Backups become ciphertext** — `backup(to:)`'s destination opened with
the SAME key (fixing the trap in research-record #10), pinned by a
zero-plaintext scan of the backup file (the 14b live-dump pattern). The
13l restore drill/runbook gains the key leg: restoring onto a NEW machine
requires passphrase, recovery phrase, or escrow.

**~~The per-note lock~~ — STRUCK at the kickoff sitting, 2026-08-27
(R13p-16).** *(The struck design, compressed for the record: one additive
synced column on `container`, migration `v1_15`, ONE §12 lockstep event
marker 7→8 via `Server/supabase/11_phase13p_protection.sql`, and
existence-without-content display rules across every content-showing
surface. Its own closing line — "no crypto machinery per note, that is
the point" — is exactly why it fell: inside an unlocked app such a gate
is a curtain, not a boundary. Consequence: this phase now carries NO
schema change and NO lockstep event; the marker stays 7 and `11_…` is
unclaimed — 13y's event takes the next number.)*

**Search speed** (her 2026-08-24 question, answered into the design): an
FTS5 query walks the term's B-tree — it touches a tiny, bounded set of
index pages regardless of corpus size, so page-decrypt overhead on search
is flat and small; a full-corpus LIKE-scan road would decrypt every page
per search, which is exactly the road 13o should decline at scale anyway.
Encryption therefore STRENGTHENS the FTS5 case for 13o — contingent on
spike Q1.

## BATCH 0 — THE SPIKE (evidence before commitment; produces a decision memo, the Phase 6 pattern)

Throwaway target or scratch branch; nothing lands in `main` but the memo.

- **Q1 — FTS5 in the prebuilt binary?** Link the forked-GRDB + SQLCipher
  package in a scratch target; `CREATE VIRTUAL TABLE t USING fts5(body)`.
  If ABSENT: contingencies, in preference order — ask Zetetic (the package
  is first-party and active), build SQLCipher from source with
  `--enable-fts5` as our own xcframework, or hand 13o the non-FTS road.
  The memo records which.
- **Q2 — Perf against P1**, on real hardware BOTH platforms: the Phase 4
  benchmark harness over an ENCRYPTED copy of a real-scale corpus;
  keystroke-road costs; open latency with the raw key (expect ~instant);
  delete-heavy ops with `secure_delete` on vs off (feeds the keep-or-tune
  knot); WAL/reader-pool concurrency sanity (readers during a write).
- **Q3 — The Keychain probe**: `SecItemAdd` with `kSecAttrSynchronizable`
  + biometric `SecAccessControl` → expect `errSecParam` (pins the
  two-item design as platform fact, not lore).
- **Q4 — Fork mechanics end-to-end**: the four-line GRDB fork under our
  org, `Package.swift:15` swapped to it, `SQLITE_HAS_CODEC` in the right
  targets, VariorumCore + BOTH apps build and their suites run green
  against an unkeyed in-memory store (proving the test factory is
  untouched before any keying work begins).
- **Q5 — Backup-trap red pin**: against a keyed scratch store, prove the
  UNKEYED `backup(to:)` destination reads as plaintext (the red half of
  Batch 1's pin — the hallucination-guard discipline applied to a trap
  found by reading).

## BATCH 1 — THE SUBSTRATE

Dependency swap (`Package.swift:15` → the Variorum GRDB fork; app-target
build settings); store-key mint + device-Keychain custody (Auto-mode item
first); keyed `configuration()`; the one-time migration with its
crash-safety tests (kill-mid-road drills on a COPY of her real store,
never the live one); `backup(to:)` keyed + the zero-plaintext backup pin
(green half of spike Q5); the recoverable-open path (`openStore(at:)`)
keyed; acknowledgments surface with the Zetetic attribution; full suites
green both platforms; a zero-plaintext scan of the migrated store file as
the batch's acceptance pin. Expectation, stated so drift is visible:
**zero `Sources/VariorumCore/Sync/` lines** (the engine reads through the
connection); if any Sync/ line proves necessary, the standing Fable rider
applies to it.

**BATCH 1 RIDERS FROM THE SPIKE MEMO (2026-08-27 — binding; the memo is
`notes/plans/phase-13p-spike-memo.md`):**
- **THE ONE-COMMIT RULE (memo Q5, the hard sequencing instruction):**
  keying the store and keying `backup(to:)` land in the SAME commit —
  `backup(to:)` THROWS on a keyed store (*"backup is not supported with
  encrypted databases"*), so 13l's scheduled backups, second destination,
  freshness face, and restore drill all break at the first post-migration
  run otherwise.
- **The corrected pin shape:** RED on pre-fix code = the shipped
  unkeyed-destination path THROWS against a keyed store (never "leaks
  plaintext" — that assertion can't go red, the call throws first);
  GREEN after = the same call succeeds, ciphertext header, byte-scan
  finds no seeded prose, AND the file reopens with the key and reads the
  prose back; the plaintext-store control (today's backup DOES contain
  readable prose) keeps the green half non-vacuous.
- **Key via the SQL pragma in `prepareDatabase`; NEVER
  `db.usePassphrase`** — that method is the KDF road (measured 165 ms vs
  ~1 ms; GRDB has no raw-key convenience). A comment at the call site
  cites the number so nobody "tidies" it later.
- **The `Package.swift` change is ONE LINE** (the dependency swap). No
  `SQLITE_HAS_CODEC` on VariorumCore, no app-target build settings —
  this rider supersedes the batch text's "app-target build settings"
  phrase (memo Correction #2: an unused define invites a future reader
  to think something depends on it).
- **The fork's delta stays a pure recipe application** — `from: "4.11.0"`
  already resolves 4.18.0; no version bump.
- **Migration atomicity comes from the verified file swap, NEVER a
  wrapping transaction** — ATTACH/DETACH cannot run inside one
  (`sqlcipher_export()` runs via `writeWithoutTransaction`; measured
  ~125 ms for a full 10k-block corpus).
- **First act of the batch:** push the local `variorum-sqlcipher` branch
  (`404dde041`, in `~/dev/scratch-13p-spike/GRDB.swift`) to the GitHub
  fork once it exists, swap to the `url:` form, and re-verify resolution
  — the memo's one named residual.
- The spike's scratch branch `spike/13p-batch0` (`ea41482`) holds the
  prototype keying seam and the Q2/Q5 harness as REFERENCE — it never
  merges; Batch 1 writes its own production shapes.

## BATCH 2 — CUSTODY, MODES & RECOVERY

Passphrase + recovery-phrase wraps (14b machinery reused; one secret,
R13p-4); the escrow item + its dial (R13p-6); the three at-open modes
(R13p-5) incl. the locked lobby and the deferred-start of
sync/bridge/janitor; re-lock policy with the teardown/rebuild tests, plus
the manual Lock Now act (demanded modes only — see THE DESIGN); reminder
checks (R13p-9 — compose with, likely reuse, 13l's shipped passphrase
sanity-check face: the reminder is that same read-only unwrap attempt on
a cadence, so one face should serve both rather than two faces teaching
one act); the reset door (biometric-confirmed re-wrap,
red-pinned: the old wrap must stop unwrapping); the Standard/Locked-down
presets as dial-setters (R13p-7); settings copy in the honesty grammar
(each mode says exactly what it does and does not protect). *(Amended
2026-08-24 per R13p-14: there is no 13l caveat to retire — the lock
moved HERE before 13l built it, so this batch SHIPS the gate faces
outright rather than upgrading an existing lock's wording.)*

## BATCH 3 — ~~THE LOCKED-NOTES FACE~~ DISSOLVED AT THE KICKOFF SITTING (R13p-16)

Not built, probably ever — her ruling, recorded verbatim in the
constitution. *(What it would have been, kept as the record of the
decline: migration `v1_15` + the §12 lockstep event; lock/unlock-note
operations with refusal grammar; existence-without-content gates swept
capability-matrix style across every content-showing surface.)* The
phase proceeds Batch 0 → 1 → 2 → 4.

## BATCH 4 — HONEST COPY, MOBILE FACES & ACCEPTANCE

The disclosure sentences per mode/preset (her voice can land later via
13s; this batch ships honest placeholders); **mobile's named deliverable
(MobileSoul §6 — inside the phase, not a parity row)**: the phone inherits
the substrate by construction (core `Persistence/`), and this batch builds
its faces — Face ID at open, the locked lobby, the settings/preset
surfaces *(the locked-note gates struck with Batch 3 — R13p-16(f))*; the
whole-app acceptance walk; `/Applications/Variorum.app` refresh + her
phone install (the standing ritual).

**THE MOBILE-ONLY-USER EXPANSION (author rider at the Batch-1 GO,
2026-08-30 — verbatim: "make sure that the mobile plan is thoroughly
updated with what it'll need too in terms of autominting on keychain,
setting passphrase, etc. some people will be mobile only users").** The
phone is a FIRST-CLASS BIRTHPLACE of stores, never merely an inheritor
of a Mac-migrated one. Batch 4's deliverable therefore includes, named
at design time (the parity-ledger record is MobileSoul PL-15):
- **(a) First launch ON THE PHONE mints the store key** silently into
  the iOS Keychain (the knot-4 ruled shape verbatim on iOS: Auto
  default, zero ceremony, escrow per preset) — a mobile-only stranger
  gets the full Standard story with no Mac anywhere.
- **(b) The phone's existing store migrates** via the same one-time
  `sqlcipher_export` road on first keyed launch (her phone's real store
  is such a store).
- **(c) The at-open modes on iOS**: Auto / Face ID
  (`.biometryCurrentSet`) / Passphrase, with the locked lobby — nothing
  runs before unlock in the demanded modes (no sync round, no local
  purge janitor, no capture surface writing).
- **(d) The passphrase-set screen with same-screen recovery-phrase
  display**, phone form factor (brains in core, faces per platform).
- **(e) The Standard nudge's two-offer shape** (create a passphrase ·
  take the recovery phrase either way).
- **(f) The escrow dial** with the ruled plain-consequence pair (iCloud
  Keychain is iOS-native; same two-item design).
- **(g) Re-lock on background as the phone's re-lock dial** + the
  manual Lock Now act in demanded modes (the hand-someone-your-phone
  case — a REAL boundary here, key material dropped).
- **(h) Reminder checks + the reset door on the phone** — and the loss
  math stated honestly in the phone's settings copy: a mobile-only user
  has ONE enrolled device, so their chain is shorter and the copy must
  say so (her knot-6 per-mode instruction binds here identically).
- **(i) A DESIGN EDGE flagged now so it is decided, not discovered:**
  the home-screen quick note mints into the store, which requires the
  key — under the demanded modes, quick capture must demand unlock
  first (honest refusal; never a plaintext side-channel buffer).

## VERIFICATION (phase acceptance)

- Full suites green BOTH platforms at the then-current baseline
  (re-baseline from the latest closeout; the known intermittent Mac
  latency pin re-runs isolated per its KnownIssues row before any
  conclusion).
- Convergence suites green over the encrypted store, byte-unchanged
  expectations (the engine never sees the cipher).
- The migration drill AND the 13l restore drill re-run end-to-end with
  the key leg (ciphertext backup → new-machine-shaped restore via
  passphrase AND via recovery phrase AND via escrow when on).
- Zero-plaintext scans: the store file post-migration, a fresh backup,
  and — unchanged from 14b — the mirror.
- P1 pins within budget on the spike-measured numbers; the perf deltas
  recorded in the closeout.
- ~~The capability-matrix sweep of protected-note surfaces~~ *(dissolved
  with Batch 3 — R13p-16; the at-open gate's acceptance lives in the
  locked-lobby tests: NOTHING runs or renders before unlock in the
  demanded modes).*
- The tutorial spine: green; whether a privacy lesson JOINS the spine is
  a sitting call (open knot), never a silent skip.
- MOBILE PARITY LINE per the closeout ritual — expected: "mobile's faces
  shipped inside the phase" (the §6 escalation satisfied), plus any
  residue named.

## OPEN KNOTS FOR THE KICKOFF SITTING (the ONLY things not ruled)

*(SITTING UPDATE, 2026-08-27 — knots 1, 2, 5, and 7 are DISSOLVED by
R13p-16 (per-note locks dropped; the bridge untouched; nothing for the
snippet brain to gate — and knot 7's premise had already inverted with
the resequencing, 13p now running before 13u). Knots 3, 4, 6, and 8
remain live; their rulings land in the RUN RECORD below.)*

1. **The lock's semantics vs. the model**: what exactly carries the flag
   (`container` only, or may a READING/book be protected — the design
   note's old protected-books knot); interaction with the seal, archive,
   Trash rows, and structural ops (a block moved OUT of a protected note;
   merge across protected/unprotected); what the Trash/tray listings show
   for a protected note (title? existence only?).
2. **The Fragments bridge asymmetry**: a protected JOURNAL note is still
   the bridge's subject — does a locked day keep pushing to Fragments
   (where the Fragments app displays it)? Her call; possibly a
   contract-file conversation (the design note's standing knot).
3. **secure_delete keep-or-tune**, decided on spike Q2's measurement
   (the keep case carries the 13j "really deleted" synergy).
4. **Recovery-phrase UX for signed-out local-only users** (generate at
   first launch vs. nudge later; what Standard preset does with it).
5. **Whether the locked-notes face (Batch 3) ships inside 13p or
   immediately after** — both she and the plan lean inside; sequencing
   taste at kickoff.
6. **Tutorial**: does a privacy/lock chapter join the spine (13j's
   deletion-chapter precedent)?
7. **Snippet/display interplay with 13u item 4**: the derived
   display-name brain must respect protection — confirm 13u's shipped
   shape and place the gate in ONE brain, not per-surface.
8. **The escrow setting's exact wording** (the one-sentence trust
   statements, each way) — copy taste, hers.
9. ~~**THE TWO GATES must become ONE story**~~ — **DISSOLVED BY HER
   RULING, 2026-08-24, hours after it was written** (R13p-14 above):
   the lock MOVED here before 13l built it, the system-password
   fallback is RETIRED (*"we don't need system password allowed
   anymore - we have a better story and a more cohesive approach
   now"*), and the answer is SUBSUMPTION — the at-open mode IS the
   one gate; nothing stacks in front of it. *(The knot's original
   text described 13l shipping the lock first under its
   plaintext-era fallback ruling; that never happened. Kept struck
   as the record of why R13p-14 exists. The residual it left — whether
   the presence case needs anything beyond R13p-7's re-lock policy —
   was RESOLVED by the planning agent's review pass, 2026-08-24:
   NOTHING remains for the sitting. The re-lock dial (sleep / screen
   lock / idle) covers unattended presence, and the one gap it had —
   "I'm walking away RIGHT NOW" — is closed by the manual Lock Now
   act added to THE DESIGN and Batch 2, demanded modes only. Under
   Auto there is deliberately no presence gate of any kind: that is
   the ruled Standard behavior, not a hole.)*

## WHY THIS PHASE IS SHAPED THIS WAY (one paragraph, for the cold reader)

The author's derivation, preserved because it explains every choice above:
E2EE sync alone leaves the disk plaintext; an app lock alone is presence
theater over a readable file; per-note crypto (shape B) excludes locked
notes from search and drives ciphertext through every read surface; whole-
store encryption closes the file door once, makes the app lock real, lets
search index everything and gate only display, reduces per-note locks to
honest access gates, and makes the "only the writing you expose goes to
AI" sentence true by construction. The presets keep the normie cost at
zero (auto-open, escrow on) while the Locked-down dials serve the
journalist and the sensitive diary. One secret, four-to-five independent
failures between her and loss, and one deliberate plaintext escape.

---

## THE ARCHITECT CONSTITUTION (P-1…P-9 — copied per the `/architect-phase` skill; byte-verbatim from `notes/plans/phase-13b-make-it-work.md`, BINDING on all 13p work beside R13p-1…15)

- **P-1 — One capability registry.** Every user-facing act is declared
  exactly once: verb, scope (block/take/post/book), per-mode availability
  rule, its doors (menu / context / bar / shortcut / palette), and its
  refusal copy. Surfaces render their doors FROM the registry; gating is
  data, never per-view if-statements. A registry-walk test asserts every
  declared door exists and every rendered door is declared. This kills the
  D3/D4 class structurally — the capability matrix stays green by
  construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act —
  including any mode-switch choreography, done visibly for the user — or
  delivers the operations layer's real refusal. A door that can never act in
  its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface
  component (live + read modes; one measurement brain — the width-gated
  remeasure; the shared canary) that every pane composes; the live editor
  core's identity machinery (`BlockRangeIndex`, crystallization) becomes its
  live mode, not a sibling implementation. "What text does this pane show,
  and is it live" is answered by ONE pure, unit-tested authority
  (`PaneTextAuthority`); views never re-derive it. Its invariants stated as
  code: exactly one live pane; the live pane is buffer-authoritative; read
  panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter
  may announce that something happened (mode changed, post opened); no
  listener derives business state or availability from a broadcast, and no
  flow's correctness depends on broadcast ordering. Cross-feature flows
  route through composition. (Stage 0's survey enumerates today's
  notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule
  marks an under-architected feature. The response is never another patch:
  write the feature's DESIGN MEMO — intended behavior whole, edge cases
  enumerated on paper, refusal wordings, undo story — get the author's
  rulings on the product-flavored edges, then build to the memo. Happy path
  ships first, but the edges are *decided at design time*, not discovered by
  the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial
  flow is the contract for every happy path. It stays green — automated
  where the harness allows, screenshot-walked otherwise — and any change
  that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive
  harness: the ops-layer soaks (exist), the board/view-model invariant soak
  (Stage 1), the registry walk (P-1), the per-batch scripted screenshot
  walkthrough. Red-on-old stays absolute: no bug-class fix without a pin
  that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind
  the rebuilt layer exactly as they bind the substrate (invalidation ∝
  realized rows; one live editor; virtualized long views). Overlays, never
  rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit`
  (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary.
  Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing
  board layout, text authority, and gesture routing splits by concern
  (`TakesViewModel` at 890 lines is the standing counterexample). Same
  hygiene rule as the substrate, applied where it was being waived.

*(The skill's application notes — P-1's routed-vocabulary scope, P-3's two
deliberate surface kinds, layer placement, the overlay/sink delivery law —
bind by reference to `.claude/skills/architect-phase/SKILL.md`.)*

---

## RUN RECORD (the running ledger — newest at the bottom)

### Kickoff, 2026-08-27 (the architect session)

**First acts executed, per the kickoff section:**

1. **Master-plan row RECONCILED** — the 13p row's stale shape-B body
   replaced with the ruled whole-store shape; this file named as the
   binding record; the pointer rider's job done. The row also records the
   resequencing consequence for the mobile second manifest: mobile resumes
   POST-LAUNCH, so its closeout's manifest lands on a post-launch Mac
   phase, not this one — **verified at this kickoff: no second manifest
   exists** (mobile round 2's closeout, which hands it, has not happened).
2. **Starting state VERIFIED:**
   - Baseline re-adopted from the latest closeout (the post-13l polish
     round, 2026-08-25): core **1416/146** · Mac **1768/296 FULLY GREEN** ·
     spine **68/9** · mobile **486/78**. Per the standing rule, suites run
     at batch ends, never at session start — these are the baseline.
   - Lockstep marker: `SyncSchema.lockstepVersion = 7`
     (`Sources/VariorumCore/Sync/SyncSchema.swift:90`); highest mirror DDL
     is `10_phase13j_purge.sql`. **The plan's 7→8 / `11_phase13p_protection.sql`
     assumption HOLDS** — no intervening phase moved the marker.
   - `grep -rn "mmap" Sources App` — **still empty** (research-record #4
     re-confirmed).
   - Working tree clean at `bff21d4` (the launch-strategy sitting's
     closing sweep).
3. **Cast recorded** (her kickoff call): Fable architect/orchestrator ·
   Opus implementers, a fresh session per batch · ONE Fable cold review at
   phase end. Sync/ rider standing.
4. **A knot-7 PREMISE INVERSION, noted for the sitting:** knot 7 was
   written under the pre-2026-08-25 order (13u before 13p) and asks to
   "confirm 13u's shipped shape" for the snippet brain. 13p now runs
   FIRST — 13u item 4's derived display-name brain does NOT exist yet.
   The knot inverts: 13p defines the protection-display authority as ONE
   brain (the R13p-10 pattern — a ruled input handed forward), and 13u
   builds its snippet function to consult it. Presented at the sitting in
   this corrected form.

Next: the kickoff sitting (knots 1–8), then Batch 0.

### The kickoff sitting, 2026-08-27 — part 1: her challenge, and R13p-16

The sitting opened on knot 1's question batch. She stopped it at the
premise — *"I'm confused - why is there a distinct protection flag?
isn't the point of this phase that the whole store is being
encrypted?"* — and, after the architect laid out the two layers (the
file vs. the screen; the curtain-not-boundary mechanism; Apple Notes'
per-note lock is real only because it is per-note CRYPTO, i.e. the
retired shape B), pushed back on all three of the curtain's supports,
each conceded: the at-open setting already serves the scared user
(R13p-5); the 13n grant is allowlist-shaped (*"granting particular
notes, not \*not granting\* locked notes"*); and an in-app gate over a
resident key is *"the same security theater that day one is doing."*

**Her RULING became R13p-16** (the constitution, above — her words
verbatim there): Batch 3 is not built, probably ever. Consequences
(a)–(g) executed the same turn: the master-plan 13p row amended, the
13o row's handed input simplified, THE DESIGN's per-note paragraph and
Batch 3 struck, the non-goals grown, knots 1/2/5/7 dissolved. The
phase now carries ZERO schema, ZERO lockstep (marker stays 7), and
expects zero `Sync/` lines end to end.

Remaining live knots — 3 (secure_delete), 4 (recovery-phrase UX),
6 (tutorial chapter), 8 (escrow wording) — ruled in part 2 below.

### The kickoff sitting, 2026-08-27 — part 2: knots 3, 6, 8 ruled; knot 4 opened into the first-launch question

- **KNOT 3 RULED — secure_delete stays ON unless the spike breaches.**
  Her pick of the recommended shape: deleted means overwritten (the 13j
  "really deleted" synergy), and only a real P1-budget breach on the
  delete/purge roads measured by spike Q2 brings the question back via
  the decision memo. Otherwise it never returns to her.
- **KNOT 6 RULED — YES, a short tutorial chapter joins the spine.** Her
  instruction, verbatim: *"yes, short chapter, and make the options
  that are in settings clear (require lock every time to open, don't,
  what you need to reset it, saving it in keychain or not, etc.). It
  should also be clear to a user everything they have to lose to lose
  their writing AND that there's an option for a plaintext backup if
  they want. basically give them their options in a non scary way, but
  in a serious way (these 5 things have to ALL go wrong for you to lose
  your stuff. unless it's on lock every time, then not having it in
  keychain and not knowing it is enough."* Binding consequences for
  Batch 4: the chapter teaches the SETTINGS OPTIONS themselves (the
  at-open modes, the reset story, the escrow dial), states the LOSS
  MATH **PER MODE** honestly (Standard's all-N-things-must-go-wrong vs.
  the demanded modes' shorter chains — her own example: passphrase-
  every-open with escrow off means forgetting the passphrase without
  the phrase written down IS enough), names the opt-in plaintext
  backup, and lands non-scary but serious. Placeholder copy now, her
  voice at 13s per the standing split.
- **KNOT 8 RULED — the plain-consequence pair.** ON: "A copy of your
  key is kept in your iCloud Keychain — if you lose this Mac and forget
  your passphrase, signing into iCloud on a new device can still unlock
  your library." OFF: "Your key stays only on your enrolled devices.
  Lose them, your passphrase, and your recovery phrase, and your
  writing is unrecoverable — by anyone." Direction ruled; 13s may
  re-voice the exact words.
- **KNOT 4 OPENED INTO THE REAL QUESTION** — her words: *"they have to
  set a passphrase, right? it should show to them on the screen where
  they set their passphrase. or do they not have to set a passphrase
  during the first launch of the app?"* One piece is ADOPTED as ruled
  regardless of the answer: **wherever the passphrase-set screen
  appears, the recovery phrase is generated and shown ON THAT SAME
  screen** (one moment, two artifacts). The first-launch question
  itself — whether Standard requires a passphrase at all — answered by
  the architect and ruled by her in part 3 below.

### The kickoff sitting, 2026-08-27 — part 3: knot 4 ruled, the fork authorized, Batch 0 launched

- **KNOT 4 RULED — NO passphrase at first launch.** Her words, verbatim:
  *"I think it's nice that the first launch mints the random store key
  and puts it in the device keychain - that's great for onboarding and
  first impressions, and I do think that the recovery phrase should
  generate and display when they choose a passphrase. I agree with your
  recommendation."* The ruled shape: first launch mints the store key
  silently into the device Keychain (Auto mode), escrow per preset — a
  stranger is writing in an encrypted library in seconds, zero
  ceremony. The passphrase-set screen is summoned by the doors that
  need one (Biometric mode — its fallback IS the passphrase; Passphrase-
  every-open; the Locked-down preset; escrow-off; sync enrollment), and
  the recovery phrase generates and displays ON that same screen.
  **HER AMENDMENT, same ruling:** *"I do think the standard nudge
  should offer for them to create a passphrase though, even if it gives
  them the recovery phrase."* So the Standard nudge (R13p-7) offers
  BOTH: create a passphrase (opening the set-screen, phrase displayed
  alongside) and the recovery phrase itself either way — Batch 2 builds
  the nudge to this two-offer shape.
- **The GRDB fork AUTHORIZED on her account** — her words: *"you can
  run the fork via gh on my account."* **BLOCKED AT EXECUTION, machine
  fact:** `gh` is not installed and no GitHub API credential exists on
  this machine (git talks to GitHub over SSH only — pushes work, the
  fork API doesn't). Her one-act options, either fine: `! brew install
  gh && gh auth login` in this session, or one click of Fork on
  `github.com/groue/GRDB.swift` in her browser. The moment the fork
  exists the architect pushes the `variorum-sqlcipher` branch over SSH.
  The spike proceeds meanwhile on the LOCAL-CLONE road (addendum,
  amended) — nothing waits.
- **BATCH 0 LAUNCHED at her word** (*"Go ahead and start batch 0"*) —
  a fresh Opus implementer per the cast, briefed by the BATCH 0 section
  plus the BATCH 0 ADDENDUM below. The decision memo lands at
  `notes/plans/phase-13p-spike-memo.md` and is reviewed by the
  architect, then brought to her, BEFORE any committed build work.
- **Sitting CLOSED.** Every knot is now ruled or dissolved: 1/2/5/7
  dissolved (R13p-16) · 3 ruled (secure_delete ON unless breach) ·
  4 ruled (this part) · 6 ruled (the tutorial chapter, her loss-math
  instruction) · 8 ruled (the plain-consequence pair) · 9 dissolved
  pre-phase · 10 re-homed to 13x pre-phase.

### Batch 0 — COMPLETE, 2026-08-27 (verdict: GO; memo `notes/plans/phase-13p-spike-memo.md`, commit `514b04c`)

- All five questions answered with measured numbers on her M3 (the
  memo's headline table). Architect spot-checks passed: `main` pristine
  (memo-only commit; `Package.swift` diff empty; tree clean), the
  scratch branch `spike/13p-batch0` present, the fork clone + probe
  logs at `~/dev/scratch-13p-spike/`. One stale SourceKit diagnostic
  (`usePassphrase` in `AppDatabase.swift`) traced to the spike branch's
  cache and dismissed against the on-disk file (grep clean).
- **KNOT 3 CLOSED WITHIN HER RULING'S TERMS** — `secure_delete` stays
  ON: no P1-budget breach (~10 ms to securely erase 20,000 prose rows,
  on the background janitor road, nowhere near a keystroke). Per the
  ruling's own words, this does NOT return to her.
- **Q1: FTS5 PRESENT** — 13o unblocked, the contingency ladder moot,
  research record #8's open question retired.
- **Three spike corrections annotated in place** (research records
  #1/#8/#10; the six-site recipe, the no-consuming-define fact, the
  loud-refusal backup shape) and the **BATCH 1 RIDERS** appended to the
  batch — including the memo's one hard sequencing instruction: keying
  the store and keying `backup(to:)` are ONE commit.
- Suites at exact baseline against the fork on the spike branch: core
  1416/146 · Mac 1768/296 fully green (the intermittent latency pin
  passed in-suite) · mobile 486/78 (2 known issues) — the test factory
  untouched, zero source changes to build VariorumCore on SQLCipher.
- PENDING, honestly held: the GitHub-fork URL resolution (minutes at
  Batch 1, after her one click) · Q3's codesigned re-confirmation
  (Batch 2, not a Batch 1 gate) · the phone perf leg (Batch 4 on her
  device, expectation recorded).
- **GATE: Batch 1 awaits HER GO on the memo** — her kickoff
  instruction: the decision memo comes to her before any committed
  build work. The fork's one click is also hers, and Batch 1's first
  act rides it.

### 2026-08-30 — the fork exists; the URL residual RETIRED; her pre-Batch-1 sanity check

- **She forked GRDB.swift on GitHub.** The architect pushed
  `variorum-sqlcipher` (`404dde041`) to `github.com/lduarte-io/GRDB.swift`
  over SSH and proved URL-form resolution LIVE: a scratch package
  depending on the fork's real URL resolved, built, and reported
  `cipher_version: 4.18.0 community`. **The memo's one named PENDING is
  retired** — Batch 1's dependency act reduces to the one-line swap in
  the repo's `Package.swift`, already proven both ways.
- **Her upstream-CI question, answered as fact:** the fork branches from
  the **v7.11.1 release TAG** — the exact version `main`'s
  `Package.resolved` has pinned all along — never from master tip, so
  upstream master's failing build (the merged PR ~3 weeks back that she
  saw) touches nothing we ship. The spike's three exact-baseline suites
  ran against this very branch.
- **Her sustainability sanity check** (the one-and-done question) and
  her **cast offer** (Fable credits for Batch 1 if the architect judges
  it complex) answered in the sitting; the architect's recommendation:
  **Fable implements Batch 1** (the phase's single riskiest
  implementation — her real store's one-way migration — the exact class
  the standing model policy reserves Fable for), Opus takes Batches 2
  and 4, the phase-end Fable cold review stands. Her call pending with
  the Batch 1 GO.

### 2026-08-30 — HER GO; Batch 1 launched (Fable implementer)

Her words, verbatim: *"GO, I approve your cast: fable implementation on
batch 1 and whatever other batch calls for Fable. My variorum is closed,
everything is ready, and I authorize any supabase pushes that need to
happen (if any). make sure that the mobile plan is thoroughly updated
with what it'll need too in terms of autominting on keychain, setting
passphrase, etc. some people will be mobile only users."*

- **Cast ratified:** Fable implements Batch 1; the architect holds her
  latitude to assign Fable to any later batch that calls for it (Opus
  otherwise, per the kickoff cast); the phase-end Fable cold review
  stands.
- **Zero-instance window OPEN at her word** (her Variorum is closed) —
  still verified by pgrep before any real-store act, per the standing
  trap list.
- **Supabase authorization RECORDED and EXPECTED UNUSED** — R13p-16
  left this phase with no lockstep event and no server-side act of any
  kind; if a server need unexpectedly appears, that is a design
  surprise and STOPS at the architect, her authorization
  notwithstanding.
- **Her mobile-only rider EXECUTED the same turn:** Batch 4 gained the
  MOBILE-ONLY-USER EXPANSION (items a–i above) and MobileSoul's parity
  ledger gained **PL-15**, written at design time per §6 — the phone as
  a first-class birthplace of stores.
- **Batch 1 LAUNCHED** — a fresh Fable implementer, briefed by the
  BATCH 1 section + riders, the BATCH 0 ADDENDUM's environment traps,
  and the spike memo. Its record lands below when it completes.

### 2026-08-30, before sleep — her ratification, the overnight posture, and the Batch 2 cast

- **Batch 4 item (i) RATIFIED** — her words, verbatim: *"i think
  that's fine on demanding unlock first, if a user wants to set the app
  to force unlock on every open."* The quick-capture-demands-unlock
  edge goes from flagged to RULED: under the demanded modes, the
  home-screen quick note (and any capture surface) demands unlock
  before minting — an honest refusal, never a plaintext side-channel.
- **She is asleep; Remote Control connected.** The standing
  away/overnight rule governs: PROVISIONAL-and-continue on anything
  that doesn't hit an author-only hard stop; genuine hard stops are
  HELD and bundled for morning. Explicitly NOT happening overnight:
  her real store's migration (phase-end install act), any
  `/Applications` refresh, any phone install, any Keychain/TCC prompt
  path on her session, any GUI screenshot drive needing the unlocked
  machine (deferred to a morning window if the screen locks).
- **Batch 2 cast, the architect's call under her latitude:** FABLE —
  the custody/wrap work and the re-lock teardown/rebuild
  (ValueObservation lifecycles must not outlive the pool) are the
  judgment-heavy halves of the phase after Batch 1. Batch 4 is
  expected Opus.
- **Her no-iCloud question, answered into the record (it sharpens
  Batch 2's copy):** iCloud Keychain is never the bridge between a
  user's phone and computer — the SYNC TIER is (content moves through
  the E2EE mirror; a no-sync user's cross-machine story is 13x's
  library-move door). Each device mints ITS OWN store key at its own
  first launch (R13p-4's per-store key), so no store key ever needs to
  travel between devices. Escrow is purely a SELF-recovery leg for a
  device's own key. Without iCloud Keychain: the escrow dial simply has
  nothing to ride (the settings copy must say so honestly rather than
  pretend the dial works — a Batch 2 copy consequence); the user's legs
  are the device Keychain + the recovery phrase + the passphrase once
  set — and a second-device sync enrollment is BY PASSPHRASE (the 14b
  road), so yes: a phone+computer user without iCloud uses the
  passphrase, exactly as she guessed. A sync user's lost device also
  always has the deepest leg: re-sync the corpus from the server.

### Batch 1 — record (implementer: Fable, 2026-08-30)

**COMPLETE. Five commits on `main` (unpushed — the architect verifies and
pushes): `e341e74` (the swap) · `3a7a2f6` (keyed stack + keyed backups,
ONE commit per the memo rule) · `89cad74` (the migration + drills) ·
`ecc5db2` (the flip + acknowledgments) · `56696b3` (the Data Safety
pane's plain-text sentences stop overclaiming — the honesty doctrine
applied to the intermediate state; noted for Batch 2: the export
evidence row's stale marker reads as alarm while the option is off,
the toggle's face should own that state).** Zero `Sync/` lines end to end
(diff-verified per commit and across the batch), zero schema, zero server
acts — R13p-16's hardened expectation held without needing the rider.

**What landed, per scope item:**

1. **The dependency swap (`e341e74`)** — ONE line:
   `github.com/lduarte-io/GRDB.swift.git`, `branch: "variorum-sqlcipher"`;
   `Package.resolved` (root + Xcode workspace) pins the exact revision
   `404dde04154ebcf4f2975a9b032548ee19023929` and SQLCipher.swift 4.18.0.
   NO `SQLITE_HAS_CODEC` anywhere in our targets, no app-target build
   settings (memo Correction #2 honored). The memo's one named PENDING —
   URL-form resolution — retired by this commit's own resolution. Suites
   green on the swap BEFORE any keying work, all three at exact baseline:
   core 1416/146 · Mac 1768/296 fully green (the intermittent latency pin
   passed in-suite) · mobile 486/78 (2 known issues). Zero source changes.

2. **Store-key mint + Auto custody (`3a7a2f6`)** —
   `Sources/VariorumCore/Persistence/StoreKey.swift`: `StoreKey` (32
   random bytes via CryptoKit, hex form, REDACTED description so a key
   can never ride a log interpolation), `StoreKeyCustody` as a
   swift-dependencies key. `liveValue` = the device Keychain
   (`io.lduarte.Variorum.store-key`, account = the store-variant scope,
   `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`, no access control —
   the brief's Auto item exactly); `testValue` = a process-stable
   in-memory key (never the Keychain — unsigned CLI runners cannot and
   must not touch it; stable-per-process so concurrent tests' stores stay
   mutually reopenable); `.inMemory()` for tests that script mint/save.
   Batch 2 extends THIS seam (wraps, escrow, the gated item).

3. **The keyed stack (`3a7a2f6`)** — `AppDatabase.configuration(key:)`
   issues the raw-key `PRAGMA key = "x'…'"` in `prepareDatabase` on EVERY
   connection (pool writers AND readers). NEVER `usePassphrase` — the
   call site carries the mandated comment citing 165 ms vs ~1 ms
   (sweep-verified: the identifier appears nowhere but that comment).
   `onDisk(url:key:)` makes the key REQUIRED at every call site — no
   defaulted-nil silent-plaintext door. `inMemory()` is byte-identical
   and the suites prove it. `openStore(at:custody:)` resolves custody
   (explicit parameter, else the injected dependency), MINTS into empty
   custody for fresh stores (born encrypted), REFUSES an encrypted store
   whose key is gone (never minting over the emptiness — Batch 2's
   recovery roads re-derive), and REFUSES to create a store whose key
   custody cannot keep. `AppBootstrap` passes explicit per-variant
   Keychain custody — two load-bearing consequences documented at the
   call site: the A4 dev/real fence extends to keys (separate Keychain
   accounts), and the host-app-under-test uses REAL custody so hosted
   suite runs can never key the dev store under a process-lifetime test
   key. **Observed live during this batch's hosted runs:** the dev store
   migrated to ciphertext under `store-key/Variorum-dev`; NO real-scope
   item was minted; her real store untouched and still plaintext, as the
   phase-end install plan requires.

4. **The one-time migration (`89cad74`)** —
   `StoreEncryptionMigration.migrateIfNeeded(at:key:faultInjector:)`:
   `sqlcipher_export()` into a keyed temp via `writeWithoutTransaction`
   (ATTACH/DETACH cannot run inside a transaction — the rider's pin;
   atomicity comes from the verified file swap, never a wrapping
   transaction) → source WAL TRUNCATE-checkpointed and PROVEN drained (a
   non-empty survivor REFUSES the swap — the belt that closes the one
   replay window: a ciphertext store beside a plaintext WAL) → the temp
   verified by keyed reopen + per-table row-count equality + ciphertext
   header → ONE POSIX `rename(2)` → drained-sidecar sweep. Idempotent and
   re-runnable; the trigger is the file's own first 16 bytes
   (`StoreFilePresence`), never recorded state. `openStore` composes it,
   so a pre-13p plaintext store — including an old plaintext BACKUP
   restored through the door — migrates on open. The SSD-remnant honesty
   footnote is in the file header (no secure-erasure claim).

5. **`backup(to:)` keyed — SAME COMMIT as the keyed stack (`3a7a2f6`,
   the one-commit rule honored)** — the destination opens with the
   store's own key via `artifactConfiguration()` (the key rides the
   configuration closure, never crossing as bytes). 13l's machinery kept
   whole: `StoreBackup.integrityCheck(of:using:)` now REQUIRES the
   source's artifact configuration (both legs thread it), because a
   keyed store's copies are ciphertext and an unkeyed check would have
   read "could not be checked" on every copy the app ever makes — a
   consequence of the one-commit rule the batch text had not named,
   found by reading 13l's shipped code. Plaintext-era stores get the
   plain configuration and behave byte-identically.

6. **`openStore(at:)` keyed** — item 3's shape; 13l's restore road and
   13x's future adoption door ride it. The restore recipe in the runbook
   survives unchanged on the same machine (the Keychain holds the key,
   and its "an older backup is brought up to the current version the
   first time it is opened" sentence now also covers the migration).

7. **The R13p-8 flip (`ecc5db2`)** — `MarkdownInsurance` gains the
   device-local opt-in (`variorum.backup.markdownInsurance.enabled`,
   default FALSE) and `performRun` gates on it FIRST — before the
   destination and before `force`, so Back Up Now is not a plaintext
   side door. New honest `BackupRunRecord.Outcome.disabled` (distinct
   from `noDestination`; lenient-decode note recorded at the case so a
   rollback drops one log row, never the log). The grep-able unit did
   its job — one grep found it, exactly as 13l built it to be found.
   Batch 2 builds the opt-in face + the Locked-down warning sentence.

8. **The acknowledgments (`ecc5db2`)** — `AcknowledgmentsCopy` (Shared,
   so Batch 4's phone face reuses the words) + Settings ▸
   Acknowledgments on the Mac: the Zetetic copyright line and the
   SQLCipher Community license VERBATIM from the resolved checkout,
   SQLite's public-domain line (the checkout's own sentence — a
   from-memory paraphrase was caught and replaced during the build),
   GRDB MIT, swift-dependencies MIT, and the vendored CArgon2/BIP-39
   provenance from their READMEs. Copy pinned by tests.

**Suite counts (batch acceptance):**
- Core: **1430 tests / 150 suites PASSED** (baseline 1416/146 + 14 new
  tests in 4 new suites).
- Mac: **1773 tests / 298 suites PASSED, FULLY GREEN** (baseline 1768/296 + 5 new: 3 flip + 2
  acknowledgments).
- Mobile: **486 tests / 78 suites PASSED, 2 known issues** (baseline 486/78, 2 known issues; no phone
  faces built — Batch 4's, per the plan; the substrate reaches the phone
  by construction and the simulator host's dev store migrates exactly as
  the Mac's did).

**The crash-drill matrix (REAL SIGKILL, on byte-copies of her real
store — logs in `~/dev/scratch-13p-spike/batch1/`):** protocol honored —
zero instances pgrep-verified by path AND `lsof` on the store; a fresh
WAL-safe safety backup (byte-copy of db + `-wal` + `-shm` with the app
closed, sha256-verified identical) taken to
`batch1/pre-drill-backup/` BEFORE anything else; the live store never
opened, written, or migrated (read-only `cp` was its only contact; it
remains plaintext). Her real corpus on the copy: 8.5 MB, 26 tables,
1659 blocks · 1843 variants · 2015 commits · 235 containers, a LIVE
2.5 MB WAL (the realistic shape).

| run | outcome | post-crash state | relaunch |
|---|---|---|---|
| full production road (`openStore`) | migrated + opened in **0.856 s wall** (whole process) | — | all 26 table counts EXACTLY match the plaintext baseline; zero-plaintext scan clean on the store AND its new WAL |
| SIGKILL after `.exported` | exit 137 | store PLAINTEXT, old wal/shm intact (2.5 MB WAL uncheckpointed), stale `.encrypting` temp | re-migrated whole; counts exact; ciphertext |
| SIGKILL after `.checkpointed` | exit 137 | store PLAINTEXT (WAL drained+closed), temp present | re-migrated whole; counts exact; ciphertext |
| SIGKILL after `.verified` | exit 137 | store PLAINTEXT, verified temp present (rebuilt anyway — a partial temp is never trusted) | re-migrated whole; counts exact; ciphertext |
| SIGKILL after `.swapped` | exit 137 | store CIPHERTEXT (random header), temp renamed away | no-op migration; opens keyed; counts exact |

The unit-test twin of this matrix (`StoreEncryptionMigrationTests`, the
4-case parameterized crash test + the corrupted-temp verification
refusal) runs the same boundaries with a THROWN abort — the gentler
sibling (an unwound throw still closes connections; SIGKILL does not) —
which is why both exist and the record says so.

**Pin inventory (each with its red-on-old evidence):**
- **The backup pin** (`KeyedBackupTests.backupOfAKeyedStoreSucceedsAsCiphertextAndRoundTrips`,
  the memo's corrected shape): behavioral revert executed — with the
  shipped unkeyed destination restored, the pin failed with exactly
  `SQLite error 1: backup is not supported with encrypted databases`;
  with the fix, success + ciphertext header + no seeded prose + keyed
  round-trip read-back. The plaintext control
  (`backupOfAPlaintextStoreStillContainsReadableProse`) passed on BOTH
  sides, keeping the green half non-vacuous exactly as designed.
- **The flip pin** (`MarkdownInsuranceFlipTests.aDefaultRunWritesNoPlainTextEvenForced`):
  behavioral revert executed — with the gate removed, the pin failed on
  `.written` + prose on disk (the pre-13p behavior observed); restored,
  `.disabled` + nothing lands. The opt-in twin proves the old road stays
  reachable.
- **The batch acceptance pin**
  (`StoreEncryptionMigrationTests.migrationEncryptsInPlaceAndTheContentSurvivesWhole`):
  zero-plaintext byte-scan of a migrated store — no SQLite magic, no
  seeded prose, no `CREATE TABLE` DDL text — plus whole-content
  read-back. (Red-on-old is structural here: the migration is NEW code;
  the scan also ran against her real store's migrated copy in the drill.)
- Refusal pins: unkeyed/wrong-key opens refused; encrypted-store-with-
  empty-custody refused WITHOUT minting; unkeepable-custody refused
  WITHOUT creating a store; WAL-not-drained refusal is the migration's
  own guard (exercised structurally; the drill's checkpointed-kill
  covers the drained road).

**PROVISIONAL calls (2–3 options weighed, most defensible implemented,
for the architect/author):**
1. **`StoreKeyCustody.testValue` = ONE process-stable ephemeral key**
   (vs per-test minting vs a real-Keychain test scope). Chosen because
   Swift Testing runs concurrently and stores opened by one test must
   stay reopenable while another test opens its own (a per-call key
   makes cross-open tests flaky), and because unsigned `swift test`
   CANNOT touch the Keychain (spike Q3's -34018 fact). Its `save`
   accepts-and-discards; `load` never returns nil, so the mint road
   never runs under the default custody — tests exercising mint inject
   `.inMemory()` explicitly.
2. **AppBootstrap's custody is EXPLICIT, not ambient** (vs reading the
   dependency, vs a prepareDependencies override). The dependency's
   test-context default would have had the HOST APP key its dev store
   under a key that dies with the test process — bricking the dev store
   for the next real run. Explicit custody keeps the app's store real in
   every process that opens it. Consequence, observed and recorded: the
   first hosted suite run migrated the dev store under the dev-scope
   Keychain item (exactly what the next real dev launch would have done).
3. **`.disabled` is SILENT in the Back Up Now receipt** (like
   `.upToDate`) until Batch 2's face gives the setting its voice — the
   alternative (a receipt sentence naming the off state) would speak on
   every run about a designed default.
4. **`integrityCheck(of:using:)` made the configuration REQUIRED** (vs
   defaulted-plain): a future caller must decide, or every ciphertext
   copy would silently read "could not be checked". Two 13l test call
   sites updated deliberately.
5. **The runbook truth edits landed now, minimal** (backups encrypted;
   the R13p-15 age-out disclosure; the opt-in wording) — Batch 4 owns
   the full honest-copy pass and 13s the voice; leaving the runbook
   claiming weekly automatic plaintext would have been false the moment
   this batch merged. `notes/DataSafetyRunbook.md` kept byte-equal (pin
   green).

**Findings / surprises (beyond the memo's):**
- **The one-commit rule's blast radius includes `integrityCheck`** —
  13l's per-run integrity check opens copies with a bare unkeyed
  `DatabaseQueue`, so keying `backup(to:)` alone would have left every
  keyed backup reporting "could not be checked" (and the WAL-copy test
  red). Fixed in the same commit via `artifactConfiguration()`.
- **`vault-bootstrap` (the 14b headless CLI tool) cannot open an
  encrypted store**: it runs unsigned (no Keychain) in live context, so
  post-phase-end it refuses honestly ("This library is encrypted, and
  its key is not available on this device"). Its one gate act is
  history; if it is ever needed again it needs a key road (env-var or
  file custody) — recorded, not built.
- **The Q3 unsigned-CLI Keychain fact bit in the designed place**: core
  tests run keyed stores entirely through injected custody; no test
  touches SecItem anywhere.

**PENDING, honestly:**
- **Her REAL store's migration is NOT run** — by design; it happens at
  the phase-end install. The drill's copies prove the road on her exact
  bytes.
- **The scratch drill artifacts contain her real prose in plaintext**
  (`batch1/pre-drill-backup/`, `batch1/drill-master/` — outside the
  repo, same protection level as the store itself today). The
  pre-drill-backup should stand until the phase-end migration has
  succeeded; the architect decides when the set is swept.
- **Batch 2 owed items touching this substrate**: the opt-in face for
  the flip (+ Locked-down warning), the passphrase/recovery/escrow
  wraps extending `StoreKeyCustody`, the Q3 codesigned re-confirmation,
  the demanded modes + locked lobby.
- The Mac latency pin (`rewriteStrategyLatencies`) passed IN-SUITE on
  every full run this batch (the swap gate and the acceptance run) —
  no isolated re-run was owed and no red needed adjudicating.

### Batch 1 — the architect's verification & adjudication (2026-08-30)

**VERIFIED, and the batch is ACCEPTED.** Spot-checks run against the
tree, never the report: the three unpushed commits present on a clean
tree; `git diff 3c7b8b2..HEAD -- Sources/VariorumCore/Sync/` EMPTY
(zero Sync/ lines confirmed by diff, not by claim); Persistence's delta
is four files, no schema; the Mac suite log's own tail reads "Test run
with 1773 tests in 298 suites passed" + `MAC SUITE EXIT: 0`. **The
store-state sweep, every `variorum.sqlite` on the machine
header-checked:** her REAL store (`io.lduarte.Variorum` container,
`Variorum/`) is **PLAINTEXT AND UNTOUCHED** ✔; the `.debug` container's
fenced dev store (`Variorum-dev/`) is **CIPHERTEXT** ✔ (the
implementer's observed live migration — the architect's first read
mis-pathed the fence and briefly suspected the claim; the A4 fence's
`Variorum-dev/` subdirectory resolves it); remaining stale dev/simulator
stores are plaintext and will migrate on their next open, by design.

**The five PROVISIONALs — all RATIFIED by the architect** (none is
product-flavored enough to wake her; bundled for her morning AWARENESS,
not decision): (1) the process-stable test key — sound on the
concurrency + unsigned-CLI facts; (2) explicit custody in AppBootstrap
— sound, and the observed dev-store migration is the fence working;
(3) `.disabled` silent in the receipt until Batch 2's face — a designed
default should not speak on every run; (4) `integrityCheck`'s required
configuration — the no-silent-degradation shape; (5) the minimal
runbook truth edits — the honesty doctrine forbade shipping the stale
claims even one commit long.

**Sweep ruling (the implementer's PENDING):** ALL drill artifacts
(`batch1/` incl. `pre-drill-backup/` and the plaintext drill copies)
are KEPT until phase close — the cold reviewer may want the drill
evidence, and the pre-drill backup is genuine insurance for the
phase-end real migration. Swept at closeout, recorded then.

**Pushed through `origin/main` after verification.** Batch 2 launched
next — Fable per the recorded cast call — carrying its owed items from
this batch: the flip's opt-in face + Locked-down warning + the
`.disabled` voice + the export-evidence stale-marker state; the wraps
extending `StoreKeyCustody`; the Q3 codesigned re-confirmation; the
demanded modes + locked lobby + re-lock/Lock Now.

### 2026-08-30, overnight — HER AUTHORIZATION: the real migration + installs pulled forward

Her words, verbatim (mid-Batch-2, via the session): *"go ahead and do
the real store migration + applications refresh + phone install
overnight. my screen won't lock."* This supersedes the phase-end hold
on those three acts — her call, recorded as such.

**The architect's execution shape, and why:** the installs build from
the ACCEPTED Batch-1 commit **`57dd2d1`** via a separate git worktree —
NOT the live tree, which Batch 2 is actively refactoring
(`AppDatabase.swift` mid-rewrite at this moment). Rationale, stated so
nobody re-litigates it: the one-way migration should run on the EXACT
code that was SIGKILL-drilled on a byte-copy of her store — Batch 1's
accepted state — not on an in-flight refactor no drill has touched.
Batch 2's later landing then meets an already-encrypted store as an
ordinary app update, and the STANDING phase-end refresh (after the cold
review) still happens as the ritual requires. Protocol for the Mac act:
zero-instance pgrep check → fresh WAL-safe byte-copy backup
(sha256-verified) → Release build from the worktree (own DerivedData,
the implementer's builds undisturbed) → copy to `/Applications` →
launch → verify (process alive; store header ciphertext; sizes sane)
→ leave the app RUNNING (the never-quit rule — her morning finds it
open). The phone: Release build + install over the pairing; its
migration runs at HER first open (launching needs the unlocked device
— install ≠ launch, stated honestly). Outcomes recorded below when
done.

**EXECUTED, same night — ALL THREE ACTS DONE:**
- Zero instances pgrep-confirmed; fresh WAL-safe byte-copy backup at
  `~/dev/scratch-13p-spike/install-backup-20260830T131927Z/`
  (sha256-verified identical to the live file; db 5.96 MB + wal
  2.54 MB + shm — the pre-migration plaintext state, kept with the
  batch-1 artifacts until closeout).
- Mac Release built from the worktree at `57dd2d1` (own DerivedData;
  the Batch 2 implementer's tree and builds untouched);
  `/Applications/Variorum.app` replaced; launched.
- **HER REAL STORE IS ENCRYPTED**: the migration ran on first launch
  exactly as drilled — store header ciphertext, 5.1 MB (the old
  main+WAL consolidated through export), fresh 66 KB WAL; smoke scan
  zero `CREATE TABLE` strings; the app is ALIVE
  (`/Applications/.../MacOS/Variorum`) and LEFT RUNNING for her
  morning per the never-quit rule. (A window-presence check was
  skipped — it needs accessibility/automation permission; the
  known windowless-after-unclean-exit residual is documented in the
  runbook and File ▸ New Window is its cure if ever met.)
- **The phone install landed** on her iPhone 17 Pro (paired,
  *[removed for publication]*
  devicectl. The phone's store migrates at HER first open, on the
  same drilled shared road.
- The install worktree (`~/dev/scratch-13p-spike/install-worktree`)
  stays registered until closeout, then is removed with the artifact
  sweep.

## BATCH 0 ADDENDUM (the architect, at launch — spike mechanics & environment)

- **Scratch discipline:** throwaway spike work lives OUTSIDE the repo
  (or in a gitignored dir); the repo's `Package.swift` on `main` is
  untouched by the spike. The ONLY things the spike lands in `main` are
  the decision memo `notes/plans/phase-13p-spike-memo.md` and this
  file's record updates.
- **The fork — LOCAL-CLONE road for the spike (amended at launch: the
  GitHub fork is pending her one-click, part 3):** clone
  `groue/GRDB.swift` at the current 7.x release, apply the
  README-documented four-line uncomment (R13p-11's road) on a local
  branch named `variorum-sqlcipher`, and pin the scratch work to the
  LOCAL PATH + Zetetic's `SQLCipher.swift` ≥ 4.18.0. This proves every
  mechanical fact (flags, builds, suites); the one residual — SPM
  resolving the fork from its real GitHub URL — is re-verified in
  minutes at Batch 1 once the fork exists, and the memo names it as
  that residual. The local branch is push-ready for the fork.
- **Q2's corpus and platforms:** measure against an encrypted copy of a
  SEEDED real-scale corpus (the Phase 4 harness/seed machinery) — NEVER
  the real store, not even a copy, for the spike (the A1 rail; Batch
  1's migration drills are where a COPY of her real store enters,
  behind a fresh backup). Mac real hardware is the spike's measurement
  authority. The PHONE leg: expected-fast from architecture (hardware
  AES on A-series); the spike records the expectation and Batch 4's
  acceptance on her phone measures it for real — a device install is
  not a spike act.
- **Environment traps (the standing set, binding):** instance checks
  via `pgrep -fl 'Variorum.app/Contents/MacOS'` discriminated by PATH;
  NEVER quit/kill a real-store instance; NO Release builds or
  `/Applications` refreshes; core tests via `swift test` from CLI; Mac
  app tests from `App/Variorum/` with suite-level `-only-testing`;
  NEVER add a custom build configuration (SPM deps compile RELEASE
  under any configuration not named exactly "Debug", silently stripping
  DEBUG-gated oracles — the 4G trap); zsh `pipestatus`; scratch and
  screenshots in gitignored dirs; never `git checkout` over
  uncommitted work; commit but do not push (the architect verifies and
  pushes).
- **The memo's contract (the Phase 6 pattern):** ONE decision memo
  answering Q1–Q5, each with measured numbers/observed facts and a
  recommendation; Q1's contingency (if FTS5 is absent from the prebuilt)
  is RECOMMENDED in the memo and DECIDED by the architect + author
  before Batch 1; Q2's secure_delete number feeds knot 3's ruled policy
  (ON unless breach — only a breach brings it back to her); Q5's red
  plaintext-backup proof is the red half of Batch 1's pin, cited by
  path/method in the memo.
