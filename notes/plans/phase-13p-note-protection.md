# Phase 13p — Note Protection: Whole-Store Encryption & Locked Notes

**STATUS: plan AUTHORED 2026-08-24, out-of-band** — written at the author's
direct instruction at the close of her 2026-08-23/24 encryption design
conversation (an author-attended Fable session, run while Phase 13l executed
in a parallel session). The phase has NOT run. It launches at her word,
expected via `/architect-phase 13p`; the cast is decided at that kickoff per
the standing rule.

---

## KICKOFF MESSAGE (for the fresh session that runs this phase)

Read, in order: this file top to bottom (it is self-contained); `CLAUDE.md`
and the canon docs per the standing preflight; `notes/SyncSpec.md` §12 (this
phase carries ONE lockstep event); `notes/MobileSoul.md` (this phase is a
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

## NON-GOALS (named so they stay declined, not forgotten)

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
- **13n's grant grammar** — 13p only guarantees the protection flag is
  readable so 13n can exclude protected notes by default (her standing
  instinct on that row).

## THE PRE-PHASE RESEARCH RECORD (2026-08-24 — what is already settled as fact)

A Sonnet research pass (author-commissioned, citations in the session
record) plus direct repo checks established, so the phase does not
re-derive:

1. **The integration road** is R13p-11's, and it is the CURRENT documented
   road: GRDB's master README + `Package.swift` carry the exact
   fork-and-uncomment recipe pointing at `sqlcipher/SQLCipher.swift`
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
   published). Spike question #1.
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
   keys the destination and pins it (see the batch).

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

**The per-note lock** (the face): one additive synced column on
`container` (shape settled at the sitting — flag vs stamp), migration
`v1_15`, E2EE serializer classification PLAIN (ids/flags only — the 14b
completeness walk will demand the classification at build time), **ONE
SyncSpec §12 lockstep event, marker 7→8**, mirror DDL
`Server/supabase/11_phase13p_protection.sql`, deployed in HER window per
the 13j precedent. Gates are access-control + display rules (R13p-1's
layer): the editor demands unlock to open a protected note; library/list
cards, the snippet brain (13u item 4's Domain function), search results
(R13p-10), Trash/tray listings, and lineage doors show existence without
content per the sitting's ruled wordings. No crypto machinery per note —
that is the point.

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

## BATCH 3 — THE LOCKED-NOTES FACE (after the sitting rules its knots)

Migration `v1_15` + the §12 lockstep event (marker 7→8, mirror DDL, HER
deploy window, both devices refreshed in-window — the 13j choreography);
lock/unlock-note operations with refusal grammar (relationship to the
SEAL and to archived/deleted states per the sitting); the gates across
every content-showing surface — editor, cards, snippet brain, search
display rule, Trash/tray, lineage doors — swept capability-matrix style
(the 13b pattern: no silent doors, no lecturing doors); structural-op
interactions per the sitting's rulings.

## BATCH 4 — HONEST COPY, MOBILE FACES & ACCEPTANCE

The disclosure sentences per mode/preset (her voice can land later via
13s; this batch ships honest placeholders); **mobile's named deliverable
(MobileSoul §6 — inside the phase, not a parity row)**: the phone inherits
the substrate by construction (core `Persistence/`), and this batch builds
its faces — Face ID at open, the locked lobby, the settings/preset
surfaces, the locked-note gates on the phone's own surfaces; the
whole-app acceptance walk; `/Applications/Variorum.app` refresh + her
phone install (the standing ritual).

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
- The capability-matrix sweep of protected-note surfaces: no gate
  leaks content, no gate refuses silently.
- The tutorial spine: green; whether a privacy lesson JOINS the spine is
  a sitting call (open knot), never a silent skip.
- MOBILE PARITY LINE per the closeout ritual — expected: "mobile's faces
  shipped inside the phase" (the §6 escalation satisfied), plus any
  residue named.

## OPEN KNOTS FOR THE KICKOFF SITTING (the ONLY things not ruled)

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
