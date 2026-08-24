# Per-note / per-journal protection (DESIGN NOTE — for a future row)

**Status: the design record for master-plan row 13p** — created
2026-08-19 at the author's instruction ("please record the rest of the
notes we have today on the architecture of per note / per journal in a
note for a future row"); **the row was created LATER THE SAME DAY at her
word** ("just give … the particular note encryption a 13 phase because I
do want to get to it with the apple notes, genuinely encrypted shape").
**That ruling sets the DESTINATION: shape B below — the genuinely
encrypted Apple-Notes shape** — reached via A as its prefix; B-lite
(journal-class-first) is the recorded candidate road. Everything else
here binds nothing beyond her verbatim words; the 13p design sitting
rules the rest.

**What is NOT this note's scope:** the APP-LEVEL lock — ruled into 13l
the same day (whole-app Touch ID/Face ID gate, passphrase fallback,
honest wording; see the 13l brief, scope item 6). That item covers her
named walk-by-snooping threat and ships independently of everything
below. *(⚠️ SUPERSEDED 2026-08-24 — the lock MOVED to 13p unbuilt, at
her ruling during 13l: the 13p plan's R13p-5 at-open modes ARE the
lock, born real, and the system-password fallback was retired with the
move. See `phase-13p-note-protection.md` R13p-14. The walk-by threat's
answer until 13p ships is FileVault + the login password.)*

## Her words (2026-08-19, verbatim)

The original ask:

> "i've been thinking about adding a setting where people have to put in
> their passphrase or biometric unlock particular notes or books (like
> journals). what would the lift on that look like? i know right now
> things are not encrypted on the disk so i'm conflicted."

The product case:

> "I do like the idea of having my journal locked, it makes me feel like
> I would feel safer writing in it."

The honesty constraint:

> "I feel like very few people would know to extract a file from a disk,
> but i don't want to imply more protection with a password than is
> real."

The sequencing instinct (hers, and this note's standing disposition):

> "my instinct is that it is important to me but that given that
> everything has been written assuming plaintext rows, it is more of a
> design sitting and shouldn't be rushed out. it also doesn't need to be
> rushed out for v1."

## The threat-model layers (the framing that resolved her conflict)

Four layers, four different jobs — the design should always name which
one it is buying:

1. **FileVault / iOS file protection** — the device at rest (off,
   stolen, disk pulled). Already the standing 14b answer for the
   plaintext local store.
2. **The login password** — the session.
3. **The app-level lock (13l)** — present company at an unlocked,
   logged-in machine. Presence control, no cryptography, honest by
   wording.
4. **Per-note protection (this note)** — the same presence threat at
   finer grain, PLUS (only in shape B below) real at-rest guarantees
   past FileVault.

## Shape A — the per-note access gate (the mid-size phase)

A per-note flag; the app refuses to RENDER protected content until
biometric/passphrase succeeds; unlock state is session-scoped. Crypto
lift ≈ zero. **The real cost center is the redaction sweep:** content
leaks through many more surfaces than the editor — library cards,
search, the tray and Trash listings, lenses/Compare, lineage views, the
block-TOC's derived first sentence, exports, the canvas. A gate that
covers the editor but shows a first line on a card is a false promise.

- **Enforce centrally in the Queries layer** (protected containers
  redact at the query, not per-view) — the one-read-layer architecture
  makes this tractable; audit it with the 13b capability-matrix
  discipline.
- The flag column is a small additive **§12 lockstep event**.
- The phone honors the flag (Face ID); the flag syncs, so mobile is
  automatic once its faces comply.
- For a protected note, "invisible to every derived surface until
  unlocked" is the FEATURE, not a limitation — which is exactly what
  makes A a genuine PREFIX of B, never throwaway work.

## Shape B — real at-rest sealing (the large phase, if ever)

What Apple Notes' locked notes actually are. What it adds over
A-plus-FileVault: someone at the *unlocked* machine with a DB browser,
malware reading the file in-session, store copies landing somewhere
unencrypted. Real threats, narrower margin than "not encrypted on disk"
suggests.

- The entire read layer assumes plaintext rows (search, render, diff,
  the bridge's hash sweep) — this is WHY 14b confined encryption to the
  one wire boundary. B means a local-seal boundary in front of protected
  rows; big, invasive, its own design sitting.
- The primitives all EXIST (the 14b cipher, AAD discipline, the key
  vault, per-class keys). The invasiveness is read-side, not
  cryptographic.
- **B-lite, the targeted variant:** seal only the JOURNAL class locally,
  its class key held in the Keychain behind a biometric access-control
  gate (Face ID/Touch ID literally IS the key release). If the
  Apple-Notes-taught expectation ("locked = encrypted") ever needs to be
  TRUE, make it true for journals specifically rather than encrypting
  the world.

## The knots (the future sitting's agenda)

- **Protected BOOKS vs protected notes.** A note lives in many books —
  protect the membership or the note? Lean: per-note truth with a
  book-level convenience ("protect all members"), but hers to rule.
- **Visible titles while locked.** Apple Notes says yes; users will map
  to that precedent. Also the precedent's trap: Apple Notes taught
  everyone locked = encrypted — the honesty wording must carry here even
  more than at the app lock.
- **Trash/tray behavior** for protected notes (13j's surfaces are a
  sweep target like every other listing).
- **The Fragments bridge.** A protected Variorum journal is still
  readable in Fragments today (journal-class E2EE decrypts on both
  ends). Options when the phase runs: Fragments grows its own app lock
  (same walk-by logic on the phone), protection crosses the bridge as a
  contract ask, or the asymmetry is accepted knowingly. A contract-file
  conversation (`notes/fragments-bridge-contract.md`), hers to carry.
- **The 13n MCP door.** Protected notes excluded from grants BY DEFAULT
  — rhymes with §9's standing "journals excluded from 'always'" consent
  rule; the two features should share one instinct.
- **Search sequencing.** The whole-library-search row carries a KICKOFF
  PIN (added 2026-08-19 at her instruction): before the indexing is
  designed/built, ask her whether this decision needs reconsidering if
  it wasn't already handled — **the index must never contain what
  protection hides.** Even under later retrofit the cost is a re-index,
  not a redesign, PROVIDED the search design keeps the exclusion door in
  mind — which the pin guarantees.

## The search interaction & the encryption spec (2026-08-20 — folded at her instruction: "make sure all the details you told me are in the 13p plan")

**Why an index, and what it is.** Searching by scanning every note's
text on every keystroke costs corpus-proportional time — the P1 sin —
so 13o will almost certainly build an INDEX (SQLite FTS5): a separate
structure like the index at the back of a book — every word, mapped to
the notes containing it, maintained incrementally as she types; queries
become instant lookups. The crucial property: **the index contains the
actual words** — it is effectively a second copy of the entire text,
reorganized by word. Today, with everything plaintext, that is a
non-event (the index is no more exposed than the notes, same
FileVault-protected file).

**The one rule protection adds:** a protected note's words must NEVER
enter the index — otherwise encrypting the note is theater (the words
sit plaintext in the index while the note is ciphertext). Consequence,
honest and small: **a locked note is not findable by library search.**
In-note find still works once the note is unlocked and open (it reads
the decrypted buffer in memory). This is exactly Apple Notes' behavior
— locked notes don't surface in search — so users already carry the
right intuition. That exclusion rule + one honest sentence in the
search UI is the ENTIRE 13o interaction — small precisely because it
was decided before the index exists (retrofit would mean scrubbing
words out of a shipped structure, re-indexing, and a leak window).

**What the encryption will be — nothing new.** 14b already built every
hard part: AES-256-GCM, per-value random nonces, AAD binding, the
account key vault, the passphrase/recovery custody, Keychain
enrollment. Her synced data is ALREADY encrypted this way on the wire
and the mirror. 13p extends the same sealing to the LOCAL rows of
protected notes: the note's whole text family (takes, savepoints,
comments) stored as ciphertext in the SQLite file, under a
protected-notes CLASS key in the vault, held in the Keychain behind a
biometric access-control gate — Face ID/Touch ID literally is the key
release. **The lift, restated concretely:** the protection flag (one
small §12 lockstep event) · the redaction sweep (the biggest half —
every listing/tray/lens/export skips locked notes; enforced centrally
in Queries, audited capability-matrix style) · the local seal/unseal
seam on the editor's read/write path · the policy calls (bridge,
exports, Trash) · pins that a locked note's content is genuinely
unreadable in the store file. A real phase — but ZERO new cryptography.

**Her use case (2026-08-20, verbatim):** "This will also be good bc I
like to store passwords in my notes app so encryption on a per note
basis would be nice." Honest caveat recorded with it: that habit is
right ONCE 13P SHIPS — today those notes are plaintext locally (with
FileVault guarding the disk) and encrypted only on the wire/mirror.

**Her reading after the explainer (verbatim):** "I feel quite reassured
and it seems like it won't be too difficult to add encrypted notes on
particular notes locally after all, which is great."

## The honesty doctrine (hers)

One true sentence in the feature's own settings description, always:
what the lock does (hides from view), what it does not (no encryption;
FileVault covers the files). If shape B ships for a class, the sentence
upgrades to the truth it earned — never before.

## Her whole-store question (2026-08-23, the 13l kickoff sitting — recorded for the 13p design sitting)

Asked while ruling the 13l app lock's fallback setting, verbatim:

> "as a question (not building it now), what's the lift on encrypting
> everything on disk and decrypting it when the app is opened, so it's
> unencrypted while the app is in use? i'm curious what the natural
> extension would lead to - though then it would be another level to
> the forgotten passphrase risk and we certainly aren't implementing
> it right now."

**The honest lift answer given at the sitting (Fable, 13l architect):**
the shape she describes is full-database encryption, and the
off-the-shelf road is SQLCipher — **GRDB ships an SQLCipher flavor**,
so the mechanical half is bounded: swap the database stack to the
encrypted variant, key it at open, one-time re-encrypt of the store.
(It is actually better than "decrypt on open": pages decrypt in memory
on read, so plaintext never lands on disk at all — her described UX
with a stronger property.) **The real lift is everything around it:**
where the open-key comes from (the E2EE passphrase is the natural
candidate — and then a forgotten passphrase is a LOST CORPUS, the
data-loss cliff the 13l app lock deliberately does not have); the A1
backup primitive keeps working but backups become ciphertext (the
bulk-`.md` insurance becomes the only plaintext escape, which inverts
its privacy framing); exports/bridge/queries are unaffected (they read
through the connection); a measurable page-crypto overhead to verify
against P1. **And it is a different road than this note's shapes A/B:**
whole-store crypto hinges everything on one secret and protects only
against disk access, while shape B seals chosen classes at the column
level. Whether the 13p destination is B alone, whole-store, or both
layered is exactly the 13p design sitting's fork — this section is
that sitting's input, nothing is decided by it.

## Standing disposition

**SUPERSEDED IN TIMING (2026-08-19/20, her sequencing ruling):** 13p
runs **PRE-V1** — her order 13l → 13p → 13o → 13i → the readiness
phases — on the schema-before-strangers principle ("so that the last
encryption changes are already live and users get the apps with only
new features, not sql changes that might take sync offline"). What
survives of the original disposition: "more of a design sitting and
shouldn't be rushed out" — the DISCIPLINE stands (rulings before
build), only the post-v1 slotting is superseded. The 13o kickoff pin
stands but is expected to be moot (13p precedes 13o by her order); the
app lock (13l) covers the walk-by case until 13p runs.

**SUPERSEDED IN DESTINATION (2026-08-23/24 — the author's encryption
design conversation; this note is now HISTORY + input):** the shapes
A/B fork this note frames was RULED PAST. The destination is
**whole-store encryption (SQLCipher via GRDB) as the substrate, with
per-note locks as access-gate faces on top; shape B column sealing is
retired to a named non-goal** — her words: "I don't think that we need
shape B column sealing" and "I think I'm realizing that true
encryption and privacy IS the story I want … it makes journaling
genuinely feel safe - which is what I want for myself." The SQLCipher
Community Edition dependency and the fork-GRDB + official Zetetic SPM
package road were APPROVED by her 2026-08-24 ("I approve the license
and the approach"). **The binding record is now the authored execution
plan, `notes/plans/phase-13p-note-protection.md`** — its constitution
(R13p-1…13), research record, batches, and the short open-knots list
for the kickoff sitting. Read this note for the threat model's history
and her verbatim path; read the plan for what 13p builds.
