# VX-378 — cold read of the simplified Castle design (rules · lifecycle page · corrector plan)

**Reviewer:** cold design read, 2026-10-16, on worktree `~/dev/variorum-vx-305` (branch `vx-305-castle-core`). Read in
full: `notes/CastleRules.md`, `notes/plans/vx-266/castle-lifecycle.html` (source), `notes/plans/vx-378-castle-simplified.md`;
background: `vx-305-castle-core.md` §1–§2, §8's 2026-10-16 sitting block, §10; `vx-266-castle-backups-prelaunch.md` §1,
§3.1–3.8 (+ the §3/§4 header map); `vx-266/second-opinion-apple-facts.md`; `SyncSpec.md` §3; `phase-14b-suite-e2ee.md`
R-4…R-8; and the code under `Sources/VariorumCore/Protection/` (file map whole; VaultModel.swift, Leaves.swift,
KeyDoors.swift read; KeyFile/FamilyTree structure checked). Settled sitting rulings are not re-litigated; every finding
cites the exact text or mechanism it rests on. Findings that would add anything say what they add and why.

---

## A. Gaps and misconceptions

### F1 — BLOCKER · rule 14 contradicts rule 11 (and the U4 promise copied from it)

- **Evidence.** Rule 14: *"The sync key changes only when the account enters Castle, so writing made in Castle is
  sealed under a key no quiet road has **ever** held."* Rule 11: *"Your text, the server's rows and the sync key are
  Standard from now on."* The sitting (ruling 12, verbatim): *"devices keep the Castle-era sync key, **held the
  Standard way**, to read Castle-era rows."*
- **Mechanism.** The leave changes no server key, so the key that seals every Castle-era row becomes a silently-held
  custody item on every device the moment the account leaves. From the first leave on, rule 14's "no quiet road has
  ever held" is false — by rule 11's own deliberate design ("leaving is your choice about your writing").
- **Consequence if unfixed.** The plan's U4 promise *"rows written in Castle are under a key no quiet road held (14)"*
  goes red on a perfectly legal sequence (enter → leave → settle). The world cannot be built green against rule 14 as
  written.
- **Fix (removes a false promise, adds nothing).** Scope the clause: *"…sealed under a key no quiet road holds **while
  the account stays in Castle**; leaving Castle hands that writing to Standard (rule 11)."* Scope U4's promise the same
  way.

### F2 — MAJOR · one pair of secrets or many? The rules never say when words/passphrase are MINTED vs ADOPTED

- **Evidence.** Rule 2 mints twelve words **per library** at creation. 14b (R-5/R-8, as built) mints twelve words
  **per account** (the vault's recovery wrap). The rules' own "considered and not pursued" entry rejects words-as-root
  partly because it would *"create two kinds of twelve words (a local library's vs the account's)"* — but the ruled
  design still has both kinds, with no rule relating them. Rule 16 mints "a fresh key" at Make-this-my-library —
  fresh **words** too, or your current ones? Rule 13's join types the account's secret — and then what becomes of the
  joining library's own words? Stage 12 of the walk is silent.
- **The old design had the answer and the cut dropped it.** vx-266 §3.8: *"When the library's passphrase differs from
  the account's, enrolling re-wraps the library key under the account's (corner 27, kept)."* The built key doors
  already behave this way (`KeyDoors.swift`: a synced door re-wraps the key file **and** the vault in one act) — one
  pair per account is the built shape; the rules just never say it.
- **Consequence.** The lifecycle test cannot print stage 12's facts; a Mac + phone + one MakeMine user could hold
  three word sets with no stated relationship — the "understandable" core aim fails exactly where her rule 13 wants the
  join to be "the reminder."
- **Fix (adds ONE rule sentence; the re-wrap it names is already built).** E.g.: *"A synced library's passphrase and
  words are the account's: setting up sync hands the library's pair to the account; joining adopts the account's pair
  (the join re-wraps the key file); the key doors change both together. Make-this-my-library adopts the secrets you
  type at its door; only creating a library shows fresh words."* Without this sentence the core aims cannot be met —
  no simpler alternative exists because the two kinds of words already exist in canon (rule 2 + 14b).

### F3 — MAJOR · a new device cannot read pre-Castle rows: the vault needs the account's earlier row keys

- **Evidence.** Rule 14: rows stay sealed under the key current at write — no re-seal ever (sitting ruling 12 withdrew
  the leave re-seal; the plan's rule-10 row deletes the rotation choreography). The built vault holds only the
  **current** class keys plus ONE transient `previousCorpusKey` (`VaultModel.swift` — `rotationBegin` /
  `clearingPreviousCorpusKey` / `reencryptBelowRotationSeq` in `Leaves.swift`), which sufficed only because the built
  rotation **re-encrypts the corpus**. Under the rules, after one Castle entry the server permanently holds rows under
  the old key AND the new one.
- **Mechanism.** A new device joining by the twelve words (rule 26: *"the twelve words recover them from the
  account"*) unwraps the current master and reaches the current row key only — every pre-entry row is unreadable
  ciphertext. Rule 26's promise is false for all writing from before the account's first Castle entry; a device that
  lagged through two entries has the same hole.
- **Fix (adds one list to the vault format + one sentence to rule 14).** The vault carries every earlier row key
  wrapped under the current master — rule 4's shape applied to the account (*"the key file carries the library's
  earlier keys"* has an exact vault twin; the entering device holds the old keys and re-wraps them in the same one CAS
  write). Without it the account-recovery promise cannot be met; the alternative (re-seal the corpus at entry) is more
  machinery, not less. Neither the rules nor the plan (§3 rows 13/14, U2) names this today.

### F4 — MAJOR · rule 7 / stage 5's "the next open asks" contradicts the on-device road's own purpose

- **Evidence.** Rule 7: *"if it stops working (a changed Apple ID, a keychain reset), the next open asks for your
  passphrase or words and quietly makes a fresh road."* Stage 5 says the same AND lists the on-device road as a live
  quiet road in the same breath (*"The on-device road never depended on iCloud and keeps working"*). Her sitting words
  for why the on-device road exists: *"a bit of cheap coverage for the people who refuse to write their 12 words down
  or make a passphrase"* — exactly the people who **cannot answer the ask**.
- **Mechanism.** An Apple ID change kills only the Apple item; the on-device item still opens the library. With the
  key in hand the app can re-mint the Apple item silently. The only candidate reason to ask — authenticating before
  enrolling a **different** Apple ID — protects nothing: whoever holds this Mac's login already holds the on-device
  road. A keychain reset kills both quiet roads, and there the ask is right.
- **Fix (removes an ask, adds nothing).** Split the rule's two cases: *"the next open uses your other quiet road if
  one works and quietly re-makes the Apple road; it asks for your passphrase or words only when no quiet road
  remains"* — and rule 3's "first launch after a quiet road failed" reminder covers the awareness job. The lifecycle
  test cannot pin stage 5 until the rule says which behavior is true.

### F5 — MAJOR · rule 20's deliberate-restore exemption vs stage 14's "replayed file refuses" — both cannot be true

- **Evidence.** Rule 20: refuse when file and memory disagree, *"(Your own deliberate restore — a backup's library and
  key file together — is not a disagreement.)"* Stage 14: *"a swapped-in **or replayed** file — the app refuses."*
- **Mechanism.** A hand-restored own backup pair and an adversary-replayed own backup pair are byte-identical events;
  no mechanism can admit one and refuse the other. Two coherent readings:
  - **(i)** the memory recognizes the library's own old keys (the family tree) → hand restores open → stage 14's
    replay claim is false for own pairs (detection catches only foreign files and lone mismatches);
  - **(ii)** only the app's doors update the memory → a hand-restored pair refuses, and the honest road is Look
    inside / Make this my library → stage 14 holds, but rule 20's parenthetical is misleading as written — and note
    the plan's act list has **no identity-preserving restore door** (MakeMine mints a new library and "never carries
    sync identity", plan rule-16 row), so under (ii) "restore my backup" always costs the library its identity and a
    synced user re-joins the account afterwards.
- **Fix (adds nothing either way; one must be picked).** Write the chosen reading into rule 20. (ii) is the stronger
  detection and lets the memory shrink (see S1), at the price of saying the identity cost out loud; (i) keeps hand
  restores friendly and must then soften stage 14's replay sentence. The U3/U4 detection tests cannot be written until
  one is picked.

### F6 — MINOR · the walk omits the on-device road from Standard backups' road lists — and the implicit "quiet roads never traverse the history" rule is unstated

- **Evidence.** Stage 1: the key file is locked *"under this Mac's quiet roads"* (both). Stage 7 lists *"Touch ID on
  this Mac (if chosen)"* for Castle backup B. Rule 15: a copy opens with *"its own quiet road on this Mac."* Yet
  stages 3 and 4 list only the Apple road for backup A — whose key at those stages is the SAME key the live on-device
  item holds (key doors re-wrap, never re-key), so the identical mechanism that justifies the Apple-road line opens
  it through the on-device road.
- **The consistent reading** of every row on the page is: a quiet road opens any copy under a key it directly holds,
  and **never reaches through the history** (only typed secrets traverse — rule 4 names only "your passphrase or
  words"). That rule makes stages 3–8 self-consistent once stages 3/4 gain the on-device road; it should be written
  down (one sentence on the page), or U3's facts diff trips on all four rows.

### F7 — MINOR · rules 4/5/6 and stages 4/7 misstate the within-mode mechanism and over-promise "same posture"

- **(a) Wrong mechanism named.** The kept key doors **re-wrap the current key** (`KeyDoors.swift`: "They RE-WRAP THE
  CURRENT KEY"; the plan's rule-6 row keeps them). After a passphrase change an older backup opens because it is the
  *same key*, not "through rule 4"'s history — yet stage 4 says *"because the key file keeps the library's earlier
  keys"* and rule 6 cites rule 4. Harmless to roads, wrong as a stated mechanism; the regenerated page should say
  "same key" where it is the same key.
- **(b) "Same posture" is both under- and over-inclusive.** Over: stage 8 itself shows a pre-Castle Standard backup
  does NOT open with current Standard secrets after a leave (empty history) — same posture, no road. Under: in Castle,
  current secrets DO open Standard-era backups (cross-posture, via the entry's history). Honest wording for rules 4/5:
  *"…every older backup whose key the current key's history holds."*
- **(c) Rule 12's "only" has one real exception.** If the passphrase or words changed DURING Castle, then after the
  leave a **pre-Castle** backup opens only with its day's old secrets or with the Castle pair through a Castle-era
  key file's history — and if no Castle backup exists, only with the old secrets. It is not "Castle-only," but it is
  no longer openable with current secrets either, which rule 12's framing hides. One honest sentence on the leave
  screen/walk; no machinery (keeping the outgoing key file would re-grow the anchor, deliberately cut).

### F8 — MINOR · stage 11 overclaims Migration Assistant against the research and rule 24

- **Evidence.** Stage 11: *"The library, its key file and this Mac's keychain items move with you."* The research file
  (apple-facts §3.6–3.9): Apple's text is ambiguous; community reports say Local Items did **not** arrive on a new Mac
  ("can only be restored onto the exact same machine"); ThisDeviceOnly-vs-other under Migration Assistant is
  undocumented. Rule 24 promises nothing about Apple's roads.
- **Fix.** *"…your keychain items may or may not arrive (Apple's behavior — rule 24); if the quiet roads didn't
  survive the move, the next open asks for a secret and re-makes them (rule 7)."* Adds nothing; makes the page true.

### F9 — MINOR · leaving an account has no rule and no stage

- **Evidence.** The plan keeps StopSyncingHere / DeleteAccountHere / ThisMacOnly / Move (§3's act list); the old
  design re-keyed the library on every account leave (vx-266 §3.8); the rules say nothing and the walk has no stage.
- **Mechanism.** Under the new model no re-key is needed — the account never holds the library key (only row keys) —
  but a user-visible road exists with no stated outcome, and U2 would have to invent it.
- **Fix (adds one sentence).** *"Leaving an account changes none of your library's keys or secrets; the server keeps
  what you pushed (removing it is the account-deletion road, VX-212); signing back in is an ordinary join (rule 13)."*

### F10 — MINOR · an old store meeting the new build has no stated outcome

Rule 25 cuts migration procedurally (everyone exports or signs in **before** the switch — VX-329's rehearsal), but the
shipped binary will someday be double-clicked on a pre-design store. The honest outcome is one refusal naming the
export-first road. This is an edge-case handler by this review's own standard and is ranked low deliberately; it adds
one refusal string, owned by a faces phase, and belongs as a row in the gate's rules checklist so rule 25 isn't marked
"proved" while the refusal is unbuilt.

### F13 — MINOR (plan wording) · the Standard on-device item's class is under-specified

The plan's rule-7 row: *"(Castle's Touch ID item type, gate Touch ID or login password)."* A
`.biometryCurrentSet .or .devicePasscode` ACL item **prompts on every read** — if it replaced the silent item,
Standard's open would stop being quiet (stage 1 lists the on-device road as a quiet road). Note apple-facts §12: a
plain `WhenUnlockedThisDeviceOnly` item is *already* "login password or Touch ID" in honest terms (the login session
reads it silently; Keychain Access reveals it with the login password) — the simplest shape that keeps stage 1 true
may be today's silent item, no ACL at all. U2 should record the exact item class and whether the silent item survives
beside/instead of a gated one; one line in the plan prevents a wrong build. (Her ruling 9's wording "Castle's Touch ID
item used in Standard too" is the thing to reconcile, not to re-litigate.)

### F14 — MINOR (plan realism) · rule 2 × rule 9: a one-secret follow must still produce a key file BOTH secrets open — the master's words copy is the kept mechanism, and the plan never names it

- **Mechanism.** A follow types ONE secret (rule 9); the device's re-keyed file must open with passphrase AND words
  (rule 2). The untyped secret's road can only run through the vault master: library-key-under-master +
  master-under-words **copied from the vault's recovery wrap** (old design §3.5a, present in the built `KeyFile`).
  Local-only crossings have no master, so they must type both secrets — nothing else can make the wraps.
- **Risk.** U1's cut ("the anchor" out of `KeyFile`) could sweep the master wrap and its words copy as
  anchor-adjacent collateral; the plan's rule-1 row ("KEEP format 3 minus the anchor") doesn't flag them as
  load-bearing, and rule 11 never says what the LEAVE types (the old design demanded both secrets at Use Standard; the
  new rules are silent — the leave lowers protection and mints wraps, so its ask must be stated).
- **Fix (adds nothing — protects a kept mechanism).** One plan line: the master wrap + its twelve-words copy stay in
  format 3 and are what make one-secret follows satisfy rule 2; a table of "what each crossing types" (entry:
  passphrase — stage 6; follow: one secret — rule 9; leave: state it; local crossings: both).

### NITs

- **F11.** Rule 18's *"They open only through Look inside"* vs rule 16/stage 10's Make-this-my-library on an
  AirDropped library — "open" vs "adopt"; one word ("read") fixes it.
- **F12.** "on this Mac" understates the Apple road's reach: a per-Mac-NAMED Apple key is a synchronizable item, so
  the same person's **other** Macs (same Apple account, app installed) read it too (apple-facts §6) — a backup's Apple
  road works there as well. Safe direction, but the U4 fakes model propagation and will show the wider reach; say it
  once honestly on the page.

---

## B. Simplifications (ranked by how much they remove)

### S1 — the family tree shrinks to a set of fingerprints (or dies entirely under F5's reading (ii))

The built tree (`FamilyTree.swift`; old design §3.2/§3.4) carries kind-for-life, the minting Mac, made/retired dates,
two sealed homes unioned at open, and migration seeding. Every old consumer is cut by the rules: "is this copy ours"
open-rule reasoning (rule 16 — a landed copy is a new library), replacement-Mac takeover (rule 22), the route finder's
dated sentences (reduced to one sentence). The only candidate survivor is rule 20's deliberate-restore exemption —
"is this key one of ours" — a bare fingerprint **set**; under F5 reading (ii) even that goes. **Simpler rule:** "What
this Mac remembers about a library is its ID, its current key's fingerprint, its device ID and the key-file mirror."
Removes the tree type, the two-home union, the seeding and their tests. The core aims never needed the metadata:
detection (rule 20) and redundancy (rule 1) read none of it.

### S2 — the catalog's legacy-name parsing and the never-prune-legacy retention arm die with rule 25

vx-305 U2 built "the one name parser, covering every filename today's builds have written" (the union of three
parsers) and retention that "never prunes legacy flat files" (old design §3.7). Rule 25 says those stores' owners
export or sign in before the switch — so the new catalog needs only the folders this design writes
(`Backups/<library8>/<mac8>/`, Previous Libraries, safety copies). **Simpler rule:** "the catalog reads the folders
this design writes; anything else is a file Look inside can try." Removes the parser union, the legacy retention arm
and their fixtures. (The plan's rule-18 row says "KEEP, narrowed to copies" without naming this cut — name it.)

### S3 — sync-key custody simplifies from "held by what they can reach" to "held by the account's current mode"

The built rule (old design §3.2: Castle-way custody "while they reach a Castle-era key — in Castle, **and through a
leave's rotation until the previous corpus key leaves the vault**") existed for the rotation walk. With the one-write
rotation and ruling 12 (*"devices keep the Castle-era sync key, held the Standard way"*), reach-tracking has no job
left. **Simpler rule:** account in Castle → Castle-way custody; account in Standard → silent. Removes the reach
computation and its pins.

### S4 — the vault's rotation fields and walk go whole, not piecemeal

`previousCorpusKey`, `rotationStartedSeq`, `rowsBelowRotationSeq`, `reencryptBelowRotationSeq`, the completing write
and `RotationAppleCopy` (`VaultModel.swift`, `Leaves.swift`) all exist for the re-encrypting rotation and the leave's
Apple-wrap choreography, both cut by the rules. The plan's U1 list doesn't name them. Naming them keeps the cut honest
and makes room for F3's earlier-keys list, which **replaces** the previous-key field rather than joining it. Removes
five fields, one leaf method, and their crash arms.

*(Considered and NOT proposed: folding ResetPassphrase into ChangePassphrase — the reset's authorization road
(words / Touch ID instead of the current passphrase) is user-visible and her ruled road; it stays.)*

---

## C. The plan's shape

- **C1 — the four-unit split is sound.** Cut → additions → lifecycle proof → world+soak is strictly ordered, each a
  coherent session; U1-as-mostly-deletion with compiling stubs is the right first move, and the ~50% line-count drop is
  plausible against the real file map (Migration, LegacyReaders, HardwareMarker, CastleAnchor, SharedKeyAndRelink,
  OpenCopy/Land, corner-45 and secretless arms in Assess — all verified present; 17 starting states → ~8).
- **C2 — the gate is honest; two tightenings.** The discovery run (seeds 21–40 green BEFORE the gate soak) directly
  answers VX-305's saturation lesson and is labeled honestly ("confirms rather than discovers"). Tighten: (a) state
  that BOTH runs land on the FINAL tree (a discovery pass followed by any fix re-runs discovery); (b) carry VX-305's
  census patch (record-every-failure-and-continue, scratch-only) as the standing diagnostic for any red soak, so a
  NO-GO sizes itself in one run instead of first-stop-per-seed.
- **C3 — regenerate-the-page is right, but make it fixture-first.** As written, U3's test prints facts and the page
  renders from the run, with "a diff of its FACTS against the target page" — but the target's facts live in prose, so
  the diff risks becoming an eyeball and the regeneration can quietly bless model behavior. Sharper shape, same work:
  extract the target page's facts NOW into one machine-readable fixture (stage × {what was written, roads per copy});
  the lifecycle test asserts against the FIXTURE (red-on-old for free); the page renders from the same fixture; a fact
  change is a fixture diff, each hers to accept.
- **C4 — missing from the kickoff brief (a fresh implementer hits each):** F2 (whose secrets at join / MakeMine /
  sync setup), F3 (the vault's earlier-keys list), F5 (which rule-20 reading), F14 (what each crossing types; the
  master-words-copy's load-bearing role), F13 (the Standard on-device item's class), and the U2↔U4 seam for rule 15's
  "the world asserts zero writes" (the world is rewritten only in U4 — say which unit owns that assertion). Each is
  one or two sentences in the plan, or a QUESTIONS row for her, BEFORE U2 spawns.
- **C5 — a hand-forward is missing: the server's `key_vault` lockstep event.** The rules change the vault's wire
  shape — the Apple wrap and `apple_key_id` leave (rule 13), a mode flag arrives (rule 11 / plan U2), F3's
  earlier-keys list, the rotation fields and `sync_reencrypt` retire. That is a SyncSpec §12 lockstep event with a
  marker bump, owned by whichever phase writes the `Sync/` half. §5's hand-forwards name faces phases only; name the
  lockstep owner now so no later session discovers it mid-phase.
- **C6 — gate item 5 (the rules checklist replacing the key map) is right** and already carries the honest "which
  later phase owns the row" column. Carry F10's refusal row and C5's lockstep row there, so rules 24–26 don't read
  "model-proved" while they are face/server work.

---

## Clean bill — load-bearing things checked and found sound

1. **Rule 13 against the 14b hierarchy as built (R-4/R-5/R-8):** the vault master wrapped by the Argon2id passphrase
   key and the BIP-39 recovery key; removing the pre-13x Apple wrap and the silent join is coherent, and "joining
   types one of them" is R-4's passphrase-enrollment road verbatim.
2. **The words-as-root withdrawal:** correctly reasoned — in 14b the words are the ACCOUNT's recovery wrap of a random
   master, so per-library derivation would fork the words and force lockstep re-encryption; the "considered and not
   pursued" entry's stated premise matches the 14b record exactly.
3. **Rule 8's Castle promise against the Apple facts:** a biometry-ACL item cannot be synchronizable (apple-facts §10 —
   `errSecParam` in Apple's own test), resists the login password (SE-evaluated, §12.4), dies on enrollment change
   with re-arm by passphrase (stage 11; §4, §8), and deleting the synchronizable Apple item propagates account-wide
   (§6, "affects all copies"). Every Castle line holds on the facts.
4. **Rule 22's plain device ID:** with B ruled (a landed copy is a new library) and takeover cut, nothing load-bearing
   reads hardware identity; a cloned Mac degrades to cosmetic per-device vault stamps (the key proof, not the device
   ID, is what gates lagging devices). Consistent with sitting ruling 13's supersession of VX-340.
5. **Rule 19's crash promise is deliverable with the kept code:** staged re-encrypt + atomic swap
   (`LibraryFileLeaf.stageReencryption`/swap), prepare-then-commit, sealed act-named plans — no in-place SQLCipher
   rekey anywhere; rule 21's delete-after-verify is already the executor's shape.
6. **The lagging-device boundary (rules 9/11/14):** enforced by the existing key proof (HMAC of the master — a lagging
   device's proof fails after the entry's master rotation) and stated honestly in the walk's don't-promise list.
7. **The cut's realism:** the plan's §3 table maps one-to-one onto the real files; the custody leaf already carries
   the item classes rule 7 reuses; `KeyFile` format 3's history/anchor separation makes the anchor a clean
   subtraction; `OpenCopy`→`LookInside` and `Land`→`MakeMine` are renames-plus-narrowing of existing acts, not new
   construction.
8. **The "considered and not pursued" list against rules 1–26:** no rule re-imports a buried idea; every entry's
   supersession pointer is accurate (anchor → 11/12; vault Apple lock → 13; repair → 20; migration → 25; hand-off →
   16/17/22; route finder → one sentence; newest-copy offer → P-U4-10).
9. **The gate's remaining items** (fixed scenarios in both configurations, mutation pins red with the guard off, the
   three-round ladder, the facts-diff recorded, both soak times recorded) carry VX-305's discipline forward unchanged.
10. **The rules document's own rule** (short, plain, no exception lists) is currently honored: the fixes above are
    scoping clauses and single sentences, not new machinery — F2, F3 and F9 are the only additions, each justified
    inline, and F4/S1–S4 remove more than the additions bring.

*Not committed — the orchestrator disposes.*
