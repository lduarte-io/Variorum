# App Strings workbook mint — the batch record (branch `tools/strings-workbook`, NEVER merges to main)

> **Not done in this batch (first line, per contract):** the MINT into her real store is HERS, never this
> session's — nothing here opens, reads or writes `~/Library/Containers/io.lduarte.Variorum/…`. No app build
> was installed; `/Applications` untouched. Road B (the one-off app door) was NOT built — Road A is viable
> (below), so the fallback stays unbuilt and its shared code path is ready if it is ever needed.

GitHub issue #5 (lduarte-io/Variorum) — the throwaway author-only generator that mints an "App Strings"
workbook book into her own store so she can rewrite the Mac app's user-facing copy inside her own app
(the 13s onboarding intake's copy-pass paragraph: `notes/plans/phase-13s-onboarding-intake-2026-10-04.md`).
Branch rule (issue #7): this branch never merges; it lives for the mint and dies after.

## LIVE STATUS

| Piece | State |
|---|---|
| P0 — road decision + this record | DONE (`P0` commit, first on the branch) |
| P1 — Package.swift targets (library `StringsWorkbook`, exec `strings-workbook-mint`, tests `StringsWorkbookTests`) | DONE (`aa430cdb`) |
| P2 — the parser (`StringsInventory`) + Swift-escape renderer + the ⏎ correction table | DONE (`aa430cdb`); tests green (P6) |
| P3 — the tier plan (`TierPlan`) + the pure workbook plan (`WorkbookPlan`) | DONE (`aa430cdb`); tests green (P6) |
| P4 — the ops-driven mint (`WorkbookMint`) + the one-shot guard + read-back verification | DONE (`aa430cdb`); tests green (P6) |
| P5 — the headless unlock road (`StoreUnlock`) + the CLI | DONE (`aa430cdb`); tests green (P6) |
| P6 — tests green (`swift build`, `swift test --filter StringsWorkbookTests`) | DONE (`5d7cbb09`) — 39 tests / 5 suites green, 55.9 s (first run: 2 reds were a TEST-HELPER ambiguity — two literals share HelperView.swift:118 and :131 — fixed in the helper; the parser was right) |
| P7 — the end-to-end rehearsal: the CLI against a scratch ENCRYPTED store laid out like hers | DONE (this commit) — every road and refusal walked; transcript summary under Verification |
| P8 — END-of-batch finals (`swift build`, the filtered suite) | PENDING |

## The road decision — ROAD A (headless executable), viable

**The custody fact that decided it.** The passphrase road needs no Keychain and no access group:

- `StoreKeyEnvelope.loadCurrent(besideStore:)` — `Sources/VariorumCore/Persistence/StoreKeyEnvelope.swift:501`
  — reads the key file (`variorum-keys-<fp16>.json`) BESIDE the store: a plain JSON file of non-secret
  wraps and KDF parameters (the file's own header, `:12`–`:21`: "deliberately not the Keychain … Holding
  the file grants nothing without the passphrase or the twelve words").
- `StoreKeyEnvelope.unwrapKey(passphrase:)` — `StoreKeyEnvelope.swift:356` — Argon2id (`PassphraseKDF`,
  the vendored PHC implementation; NFKD normalization inside `deriveKey`, `PassphraseKDF.swift:165`) +
  RFC 3394 `AES.KeyWrap.unwrap`. Pure computation; a wrong passphrase refuses (`wrongPassphrase`).
  The twelve words have the twin road, `unwrapKey(recoveryWords:)` — `:391`.
- `AppDatabase.openStore(at:custody:)` — `Sources/VariorumCore/Persistence/AppDatabase+Dependency.swift:88`
  — takes ANY `StoreKeyCustody`; `StoreKeyCustody.inMemory(initial:)` — `StoreKey.swift:170`. This is
  exactly the app's own LOBBY road: `AppBootstrap.swift:392` passes `StoreKeyCustody.inMemory(initial:)`
  for the key the lobby unwrapped, and `openStoreOffMain` (`AppBootstrap.swift:824`) documents "custody
  non-nil is the LOBBY's road … the device-Keychain custody is deliberately NOT consulted on that road".

The Keychain-gated items (the Auto/Biometric store-key items, `StoreKeyKeychain`, `StoreKey.swift:261`)
are the app's SILENT roads; the headless tool takes the typed-secret road instead, the same one the locked
lobby offers.

**Contingency (checked at run time, without any secret):** the road exists only if her key file carries a
LOCAL passphrase wrap (or a recovery wrap). `StoreKeyEnvelope.passphrase`/`.recovery` are optional — a wrap
lands only when a passphrase / the words were set on this library (`StoreKeyEnvelope.swift:64`–`:70`). The
lobby can ALSO unlock through the account vault over the network (the master-wrapped copy); the tool does
not take that road. The CLI says which local roads exist before prompting; if neither does, Road A is dead
for her store and Road B (the app door) is the fallback.

**Two facts outside custody that the road had to respect:**
- `owner_id`: the headless process runs signed out (`OwnerIdentity.liveValue = .signedOut`,
  `OwnerIdentity.swift:35`), so minted rows are born unowned; the app's `runOwnerAdoption` stamps them "at
  sign-in and at every signed-in launch" (`App/Variorum/Shared/AppServices.swift:435`–`:447`) before sync
  pushes — the same road every pre-sign-in row takes.
- The Release app is SANDBOXED; her store lives in `~/Library/Containers/io.lduarte.Variorum/Data/Library/
  Application Support/Variorum/variorum.sqlite`. A Terminal process reaching another app's container may
  meet macOS's "access data from other apps" prompt — hers to answer at the mint.

## Decisions and readings (PROVISIONAL where marked)

None of these reopen a ruling; the spec (issue #5, the 13s intake's copy-pass paragraph, the brief) is silent
on each. CANON is not edited on this branch (issue #7), so they live here, not in `notes/QUESTIONS.md`.

- **P-1 — NOTES are the inventory's 37 SURFACES, not its 28 `##` headings.** "Settings panes" is a container
  heading with ten `###` panes, each with its own footer; the doc's own Totals table counts the panes as
  rows, and Tier 3 lists them one by one. So one note per pane, titled "Settings — General" etc. Alternative
  (not built): one "Settings panes" note of 257 blocks.
- **P-2 — placement rule, PROVISIONAL.** A surface sits in the FIRST tier that names it (as a surface, or by a
  part of it), at the position of that first mention. Tier 0 names defect STRINGS by site, never surfaces,
  so it places nothing. Tier 3's explicit instruction ("Settings ▸ Protection … land with the ruled corpus
  (Tier 6)") is honoured. Two surfaces are named only IN PART: **"Seeded content" → Tier 1** (item 2, the
  welcome names) and **"Protection, encryption, account & sync surfaces" → Tier 2** (item 3, the 95
  §11-provisional strings, "yours to settle now"). Every ⚠RULED (§11 provisional) block opens its take 3 with
  that lead, so she can find them in a 561-block note. Options: (a) **built**, first mention; (b) whole-surface
  naming: Seeded → Tier 4, Protection → Tier 6 (Tier 6 names "the 561 protection-surface strings"), which
  keeps Tier 2 small but puts in-budget work in the "deliberately OUT" chapter; (c) split those two surfaces
  into subset notes (39 notes), mirroring the tiers exactly but breaking "one note per surface". The table
  is `Tools/StringsWorkbook/Sources/TierPlan.swift` (one edit to change it; tests pin it).
- **P-3 — empty chapters.** Tier 0 and Tier 4 are created and stay EMPTY: the tiers are the book's structure,
  Tier 0's strings live in their surfaces' notes, and Tier 4's documents (the field guide prose, takemania)
  are not inlined in the inventory (its Seeded-content entries are descriptions). "Unprioritized" is created
  only when a surface lands there — none does in this compile. Alternatives: a Tier 0 checklist note (not
  built — it would be a non-string note in a string workbook); always create Unprioritized.
- **P-4 — chapter names** are the priority doc's own headings minus their time-box parentheticals, parsed at
  run time ("Tier 0 — defects, not voice", "Tier 6 — deliberately OUT of the 8 hours"). The brief's
  "Tier 0 — defects" was an example; the rule is mechanical and pinned.
- **P-5 — Seeded content's seven DOCUMENT bullets** are seven blocks (the doc counts them in its 3,630). Take 1
  is the bullet's whole description (sub-bullets on their own lines, escapes rendered); take 3 lists every
  locator in it (`:N` shorthand resolved to the path before it; bare file paths included) and the tag
  `(seeded document)`. The two that carry ⚠RULED (the field guide's "keeping it private" chapter, Encryption
  Explained) lead with it.
- **P-6 — take 3's format:** `[⚠RULED lead]` / one site per line / `surface: <heading>` / `[(templated) (tooltip)]`.
  The leads are `⚠RULED — edit against notes/plans/pre-13x-copy.md` and
  `⚠RULED (§11 provisional) — edit against notes/plans/pre-13x-copy.md`.
- **P-7 — the book:** `createReading(name: "App Strings", kind: .book, profile: "book")` — no rule, no outflow,
  Home wing, unshelved, not starred; notes via `createPost` + `addPostToReading` + `assignPostToSection`.
- **P-8 — the one-shot guard** refuses any non-tombstoned reading whose name has the workbook's
  `BookNaming.key` (the E13 rule's key) — including an ARCHIVED one, which `assertBookNameIsFree` would skip.

## Findings and surprises

- **F-1 — the inventory's ⏎ is lossy (25 literals).** The legend says ` ⏎ ` marks a line break, but the sweep
  wrote every raw ⏎ glyph the same way. 23 of the 25 are the Return-key SYMBOL ("type one and ⏎ makes it");
  12 of those lost information (`(⌘⇧⏎)` reads `(⌘⇧ ⏎ )`; two LEADING glyphs were dropped:
  `QuickNoteView.swift:547`, `CommentsPanel.swift:350`). Only `AcknowledgmentsCopy.swift:149` and
  `HelperView.swift:494` are true `"""` literals, and the second mixes three line breaks with two glyphs, so
  the brief's literal rule (` ⏎ ` → newline) would have corrupted 23 strings. Resolution:
  `ReturnGlyphCorrections.swift` holds each of the 25 literals' TRUE text, extracted from source at the branch
  base (generated by script, not hand-copied), and every entry SELF-VERIFIES at parse time: the sweep's lossy
  rewrite, stated as code, must reproduce the inventory's text exactly, or the parse refuses. A ⏎ bullet with
  no verified entry refuses too. The rule ` ⏎ ` → newline therefore applies exactly where source has newlines.
- **F-2 — a site does not identify a string.** 140 source lines carry more than one inventory bullet (283
  bullets), e.g. `HelperView.swift:118` holds both "Format ▸ Inline Code" and "`like this`". The apply step
  after her pass must match take 1's text AND the site. (It also bit this batch's own test helper, which now
  refuses an ambiguous lookup.)
- **F-3 — the priority doc's counts are approximate; the inventory's are exact.** Tier 2 says "96 ⚠RULED
  (§11 provisional)": the inventory carries 95. Tier 6 says "254 ⚠RULED of the 561": the Protection surface
  carries 244 plain-ruled + 85 provisional. Every footer and the Totals table agree (3,630) — the mint
  asserts those and refuses on any mismatch.
- **F-4 — the `vault-bootstrap` precedent cannot open an encrypted store any more.** Its bare
  `AppDatabase.openStore(at:)` (`Tools/VaultBootstrap/VaultBootstrapMain.swift:101`) takes the ambient
  `\.storeKeyCustody` (`StoreKey.swift:207`, the device Keychain), which an unentitled CLI cannot read, so
  since 13p it would refuse "key not available". Not this batch's to fix; recorded for the orchestrator.
- **F-5 — the store's `-wal`/`-shm` stay beside it after a clean close**, as they do for the app at rest (the
  dev store shows a 2.3 MB WAL with no instance running). Committed data lives there until the next
  checkpoint; the reopen-and-verify test proves the mint reads back through it. The A1 rail is WAL-safe.

## Verification

**Suites** (`swift test --filter StringsWorkbookTests`, 2026-10-05): 39 tests / 5 suites green in 55.9 s —
the parser against the real compile (37 surfaces, 3,630 bullets, every footer, the tag census, escapes,
double-backtick literals, all 25 ⏎ corrections and their self-verification, the seeded documents), strictness
on synthetic docs (unknown tag, non-site locator, unverified ⏎, drifted correction, unknown escape, footer
and Totals mismatches), the tier plan (names from the doc, every surface placed once, per-chapter order and
block totals 0 · 276 · 1253 · 253 · 0 · 1669 · 179), the exact locator format, the mint (a small plan's exact
rows; the real plan's 3,630 blocks / 10,890 takes with the SQL read-back; one-shot against an archived,
re-cased twin; the verifier catching a drifted take), and the unlock road (refusals that create nothing,
roads read without a secret, passphrase and words unwrap, wrong secrets refuse, the probe's schema guard and
wrong-key failure, and the whole road on an on-disk ENCRYPTED store: mint → verify → close → reopen → verify,
her existing book untouched). The opt-in rehearsal fixture is skipped in a plain run.

**Rehearsal — the release CLI, run as she will run it** (`swift build -c release`; a scratch library laid out
like hers: encrypted store + fingerprint-named key file with a passphrase wrap at PRODUCTION KDF parameters
and a recovery wrap, one existing book and three notes; written by the opt-in `RehearsalFixture` test into
the session scratchpad):
- `--plan-only` → 3,630 strings / 37 surfaces, 25 ⏎ corrections, 7 chapters / 37 notes / 3,630 blocks /
  10,890 takes; per-chapter counts as above.
- wrong passphrase → `REFUSED — that passphrase does not unlock this library (nothing was opened)`.
- a mistyped store path → `REFUSED — no store exists at … refusing to create one`; no folder created.
- `--dry-run` with the passphrase → unlocked, schema identical (22 migrations), counts, "no App Strings
  book yet", nothing written.
- **THE MINT, interactively through a pseudo-terminal** (hidden passphrase prompt + typed `MINT`, no rehearsal
  flags) → `minted: 1 book · 7 chapters · 37 notes · 3630 blocks · 10890 takes in 37s` · `verified` ·
  `store closed cleanly`. The passphrase occurs 0 times in the transcript (echo is really off).
- a second run → `REFUSED — a book named “App Strings” already exists …` (after unlocking, before any write).
- `--recovery-file` (the words road) → unlocks, then the same one-shot refusal; a valid-checksum WRONG phrase
  → `REFUSED — those words do not unlock this library`.
- the zero-instance guard → with the DEV-STORE Debug build launched (`io.lduarte.Variorum.debug`):
  `REFUSED — a Variorum app is running (io.lduarte.Variorum.debug) — quit it first`; the instance quit by
  identity, zero instances verified after.

**Not verified here, by design:** the workbook rendered IN the app. The Debug build opens only the dev store
(whose key this session must not explore), and swapping a fixture into the dev slot has no precedent; her
first look at the mint is the first in-app render. No screens folder was named; the CLI's terminal output
above is the use evidence for a tool whose face is the terminal.

## THE CHOREOGRAPHY — her mint (Road A; about five minutes)

Nothing is installed and `/Applications/Variorum.app` is never swapped: the tool runs beside her normal build.

0. *(Orchestrator, before her window.)* A checkout of this branch that does not disturb main — e.g.
   `git worktree add ~/dev/variorum-strings-workbook tools/strings-workbook` — then from it:
   `swift build -c release --product strings-workbook-mint` (about 70 s cold) and
   `swift run -c release strings-workbook-mint --plan-only` → must print 3630 / 37 / 7.
1. *(Her.)* Quit Variorum on this Mac (every instance). Mac 2 may stay open; it receives the book by sync.
2. *(Orchestrator.)* The A1 rail: the WAL-safe safety copy into `Backups/safety-copies/`.
3. *(Her, in Terminal, from the branch checkout.)* The dry run:
   `swift run -c release strings-workbook-mint --store "$HOME/Library/Containers/io.lduarte.Variorum/Data/Library/Application Support/Variorum/variorum.sqlite" --dry-run`
   - macOS may ask "“Terminal” would like to access data from other apps" → **Allow** (it may ask again on
     the next run). If it was refused, the run fails with a permission error; System Settings ▸ Privacy &
     Security ▸ Full Disk Access ▸ Terminal on lifts it.
   - It prints whether the key file holds a passphrase copy and a recovery-words copy, then asks for the
     passphrase (hidden). Expect: `unlocked`, `schema identical to this build's (22 migrations)`, her book and
     note counts, `no “App Strings” book yet`, `nothing written`.
   - "passphrase copy: NO" → add `--recovery-words` (the twelve words, hidden). Both NO → Road A is dead for
     her library and Road B (the app door, unbuilt) is the fallback.
4. *(Her.)* The same command without `--dry-run` → passphrase → type `MINT` → about 40 s of progress lines →
   `verified: …` → `store closed cleanly.`
5. *(Her.)* Open Variorum. "App Strings" is on the Bookcase, unshelved, at the top of All. Tier 0 and Tier 4
   are empty by design (P-3). Takes mode on any note shows current · rewrite · where.
6. Sync: at launch the app stamps the new rows' owner (its standing adoption pass), then pushes about 18,232
   rows (3,630 blocks + 10,890 takes + 3,630 placements + 37 notes + 37 memberships + 7 chapters + 1 book).
   Mac 2 has the book once that drains.

**Way back:** the A1 safety copy (her rail), or Book ▸ Delete Book… with its notes (the Trash keeps them).
A mint that fails partway leaves a partial book, and the one-shot guard then refuses a re-run until that book
is deleted. The worktree and branch are removable after the mint (issue #7: the branch never merges).
