# VX-988 — the OSS fix pass (HEAD edits from the sweep rulings)

**STATUS: IMPLEMENTED (first pass + her follow-up batch + the cold-review fixes batch) — branch `vx-988-oss-fix-pass`
pushed, NO PR opened (the orchestrator's call).** Worktree `~/dev/variorum-vx-988`, off `main` at `fd021908c`. HEAD-only:
no history rewritten, no commit message touched.

## FOR A LATER READER

**Not done, first:** the OSS plan's motives line (§1, line 7) is untouched — it waits on her word; three commit messages
on this branch name a removed class (`c952778e6`, `0715f81ee`, `707684cd2`) and need VX-749 `--replace-message` rules
(history is never rewritten here); the commit-author metadata (the mailmap row) is VX-749's; and the pile-B verify rows
(the security-as-roadmap row in `notes/TICKETS.md`, home and scratch paths) are VX-751's. Everything else she ruled is
applied below.

**The mechanism.** The open-source sweep (VX-754 — piles A/B/C/P read by agent eyes) flagged sensitive content across the
history and the tree at HEAD; the author ruled every flag (rulings R-oss-N, held on the PRIVATE verdict ledger outside
this repo — the ledger never enters the repo, and this record carries ruling ids, classes and counts only, never a removed
value). This pass is the edit of the working tree at HEAD that applies those rulings, in three rounds: the first pass
(items A–F), her rulings on its survivors (the follow-up, items 1–5), then the confirmed findings of a fresh Opus cold
review plus her R-oss-39 cuts (the cold-review fixes batch). The later filter-repo rewrite (VX-749) handles every older
version of every file; commit messages, the prompt record and transcripts belong to that rewrite and to the packaging
work, not here. Removed text that had a home to go to went to the private planning repo FIRST (the OSS plan's "excision is
a relocation" rule): the relocated files, and every passage a round cut or rewrote.

**The first pass, by work item** (one commit per piece; every commit message describes the edit mechanically):

- **A · R-oss-11 — tester identity** (`c2c9da936`). The two beta testers' names, handles and addresses become **tester A /
  tester B** where one passage needs both apart, **the tester** where only one appears (22 files: the vx-440/494/500/510/
  529/601 records and handoffs, the record, the closeout archive, four code comments). Addresses removed entirely; a name
  inside her verbatim quote is bracketed (`[tester A]`); their words stay. The 13r walk's scratch macOS account (a handle
  in the same token family — no person) becomes **the test account** / `<test-account>`.
- **B · R-oss-20 — the 14b re-key suite email** (`a71e41bac`). The runbook file is already gone at HEAD; its executed drill
  step in `notes/plans/phase-14b-suite-e2ee.md` carried the address — redacted.
- **C · R-oss-25 — the personal class** (`1bdee090e` mockup take text → invented prose; `ebd18d17f` the two 18l
  screenshots removed, their three references annotated; `667d481b7` the 2026-07-25 intake trimmed to its Variorum
  sections with a marker line; `0715f81ee` two personal asides redacted (R-oss-25)).
- **D · R-oss-26 — the OSS plan's own riders** (`c952778e6`). The ruled rider sentences in
  `notes/plans/open-source-readiness.md` removed; the rest unchanged.
- **E · R-oss-23 — two files relocated** (`707684cd2`). `notes/release-and-v1-strategy.md` and
  `notes/marketing-launch-approach.md` copied verbatim to the private repo's `relocated/` (its commit `42de8ce`), removed
  here; 31 references across 18 notes say "(relocated to the private planning repo)".
- **F · R-oss-27 — identifiers** (`696495efa`). Angle-bracket placeholders by kind — `<apple-team-id>`, `<apple-cert-id>`,
  `<signing-cert-sha1>`, `<notary-key-id>`, `<supabase-project-ref>`, `<device-udid>`, `<account-uuid>`,
  `vmk1_<dev-key-prefix>…` — across 93 files; four test fixtures that carried a real account id carry the fictional
  `a0000000-0000-4000-8000-000000000001` (a fixture must stay UUID-shaped). Bundle ids untouched everywhere (her exception).

**The follow-up — her rulings on the first pass's survivors:**

- **1 · R-oss-12/16 — her addresses, ALL** (`25e1eb602`, 15 notes): `<signing-email>` (the signing-identity address,
  6 lines), `<her-email>` (her personal addresses, 15), `<oauth-account-email>` (1), `<test-account-email>` (the test
  accounts' address shapes, 9). No real test-account address sits in a guarded tool: the `someone08+vxtest-…` strings in
  `Tools/WalkKit/first-run-walk.sh` and `Tools/prod-reset-test-account.sh` (and two records describing them) are an
  invented fixture, not hers — left.
- **2 · load-bearing values — KEEP, ruled.** The production project ref (`App/Variorum/Shared/ProjectConfig.swift`, the
  three pinned `Tools/prod-*.sh`), the team id (`project.pbxproj`, `ProtectionKeychain.swift`'s keychain-group prefix,
  `Tools/Release/verify-export.sh`), and `Tools/Release/ExportOptions.plist` + the binary
  `Tools/Release/Variorum_Developer_ID.provisionprofile` (team id, signing cert, profile UUID) stay as they are; no env-file
  move. **CLOSED.**
- **3 · R-oss-27 — the remaining identifier kinds** (`a9f6e5d5f`, 52 notes): `<oauth-client-id>` (11), 
  `<provisioning-profile-uuid>` (2, notes only), `<supabase-org-id>` (2), `<auth-identity-id>` (3), `<library-uuid>`
  (21 — every library id inside a prefs key, plus the three full library UUIDs wherever they stood), `<simulator-udid>`
  (91 — 21 simulator ids, full and truncated, classified by context; commit SHAs and fixture UUIDs that share the shape
  left alone), plus two truncated signing-cert forms item F missed. No occurrence sat in shipped code or config. The 8-hex
  library/key ids in walk logs **KEEP — ruled fine, CLOSED.**
- **4 · R-oss-25 — the stragglers** (`c28950d19`): `WriteTopAirTests.swift`'s sample note is invented text of the same
  shape (four elements: a first line of the same length, blank, a short line, blank — nothing renamed; the test reads only
  block structure) and its three quotes in `phase-18l-navigation-feel.md` follow; the 09-06 use-report manifest's one real
  note title is "(a note title)" — the screenshots that table lists were never committed (the folder is gitignored, absent
  from every commit); the intake's provenance header no longer claims the file is unedited and no longer lists the removed
  sections — it says they were removed for publication and the 13c ledger remains the record.
- **5 · R-oss-23 — the ruled passages in other files** (`b44f3649b`, 34 cuts in 8 notes, each a one-line
  `*[removed for publication]*` marker): the FuturePhases 13t row (the row kept, its cells emptied to the marker); the
  14a record (two field-note rounds whole, five sub-bullets or clauses, one figure — that figure's marker was missing
  until the NITs below); the 14c record (passages in Rounds 7–8, the contract block and the gate, three embedded figures)
  and the same in the 14c handoff and gate handoff; two passages in the 13n door note; two passages in the master plan's
  14c row and one paragraph; `notes/AppSpecDeltaArchive.md`'s 14C delta (two passages — **a frozen canon archive, edited at
  her explicit word; passages cut only, nothing restructured**; the 14D delta carried none). The removed text is verbatim in
  the private repo (`relocated/oss-fix-pass-removed-passages-2026-11-11.md`, its commit `d6c2a1d`).

**The cold review (fresh Opus, whole branch + commit messages + this record + a leak check): NOT MERGE-READY** — 1
BLOCKER, 4 MAJOR, 4 MINOR, NITs; every finding confirmed and dispositioned on the private ledger. **The cold-review fixes
batch** (one commit per piece; every cut or rewritten passage copied verbatim to the private repo first — its commits
`87c6aa0` `ba2b7ed` `c1bb6b7` `9d9e308` `4974253`, appended to the same passages file under a dated batch heading):

- **B-1 · R-oss-11** (`b15fed578`): one tester name survived inside her verbatim quote as an all-caps possessive (a
  word-bounded grep cannot see it) — bracketed `[TESTER B]'S`, the record's in-quote style. The unbounded,
  case-insensitive re-grep of every tester-name family is now zero (the only substring hits are ordinary words, camelCase
  test names and the public-domain *Prince*'s "Switzers").
- **M-1 · R-oss-27** (`02e74d1f4`): two more OAuth client ids (full and truncated forms, 8 sites), a fourth library UUID
  (2 sites), one production test-account id (full and its 8-hex walk-log form) → `<oauth-client-id>` · `<library-uuid>` ·
  `<account-uuid>`.
- **M-2 · R-oss-22/26** (`4eb7b7a88`): a parenthetical pointer in the vx-912 record's her-items list, dropped.
- **M-3 · R-oss-25** (`24da5a4a1`): one personal paragraph inside the intake's kept section, removed (the file's one
  marker already explains the trim; the cut does not read broken).
- **M-4 · the standing class rule** (`ee6da94d9`): a phrase and a sentence in the mobile plan's gate-close paragraph, cut
  with markers.
- **m-1** (`ffe0bf923`): the 29 relocation annotations and this record say "private planning repo"; item C's line above no
  longer describes the asides; this record's class-naming wordings neutralized (this commit).
- **m-2** (`0269abdda` + `401d2ede9`): a 13r capture filename carried the test account's display name → `<test-account>`
  (12 lines, two notes); the open-items line that called it "ruled kept" is corrected — no ruling ever covered it.
- **m-3** (`e9c5e72fd`): the three DMARC passages (14d handoff and batch record) keep only the technical point (a TXT
  record on the sending domain; a report address on another domain needs that domain's verification TXT) — the address
  placeholder and the destination domain beside it dropped.
- **m-4** — (a) `cba065288`: the vault's two corpus key ids and two proof-hash prefixes → `<corpus-key-id>`,
  `<key-proof-hash-prefix>` (`-2` for the second), four notes; (b) `84f27c226`: four notarization submission ids →
  `<notary-submission-id>`; (c) `53c34da4b`: the ruled descriptive wording cut from three lines of the OSS plan (six
  markers), its motives line untouched; (d) `d4d3d99e4`: five unpublished launch drafts under `notes/brand/posts/` and
  `notes/brand/site/` relocated whole (the private repo's `relocated/brand/`), their references in four notes annotated,
  and `220ebc285`: one FAQ answer slot in the product-page reference and one phrase in `LAUNCH-CONTENT-NOTES.md` cut with
  markers — the rest of `notes/brand/` (the logo, PROCESS, the shipped copy) stays; (e) `f426a653b`: the remote-workflow
  cheatsheet's home-infrastructure details → `<server>`, `<user>`, `<vpn-node>`; (f) `9dc9f0a8f`: a hosted-artifact URL →
  "(an internal design link, removed)".
- **R-oss-39 — her "cut them all"** (`1c6ace58c`, `7600b5213`): the four residual figures (the master plan's 14d row, the
  closeout archive, the bridge contract, the 14d batch record — plus one parenthetical beside the archive's), five
  markers; the 14a record's two road labels reworded to "no-cost"; the 14c Round 8 heading reworded neutrally; three
  sentences and one clause elided with […] inside her Round 7 quote, and one clause inside the 13n note's chat-lean quote.
- **NITs** (`9d7b1d14f`): the 14a record's one unmarked cut carries its marker; `WriteTopAirTests.swift`'s fixture doc
  comment describes a fixture (comment only); the FuturePhases 13t row carries its pointer again ("material relocated to
  the private planning repo — the 13t kickoff asks the author", as the OSS plan promises). The two 8-hex stragglers the
  review named stay (the ruled walk-log class).

**Evidence.** The first two rounds' "zero tester tokens" claim was FALSE — the B-1 survivor was missed by a word-bounded
grep; after this batch, unbounded case-insensitive greps at HEAD find zero for every tester-name family, every value this
batch placeholdered (full and truncated forms), the capture filename, the residual figures and the old road labels;
every earlier round's scrubbed address and R-oss-27 token stays zero outside the load-bearing files (follow-up item 2).
`swift test --filter AccountVaultWireTests` 13/13 green and `Tools/WalkKit/first-run-walk.sh --self-test` exit 0 (72
guards), after every round. The app-target test files changed only by a string literal or a comment (not run: an
`xcodebuild test` needs a stage claim).

**Open items:**

1. **The OSS plan's motives line (§1, line 7)** — her word decides it; untouched.
2. **Three commit messages name a removed class** (`c952778e6`, `0715f81ee`, `707684cd2`) — no value quoted. History is
   never rewritten here: VX-749 needs a `--replace-message` rule for each. (The reviewer's scope note for VX-749 stands:
   the rewrite must cover every prose cut and relocation of all three rounds in every parent blob, not tokens alone.)
3. **The mailmap row** — the commit-author metadata is VX-749's, her call on the target address.
4. **The pile-B verify rows** — the security-as-roadmap row in `notes/TICKETS.md` (a generated snapshot; the fix belongs
   on the board), home and scratch paths: VX-751's verify list.
5. **Kept on purpose, all ruled:** the load-bearing values (follow-up 2); the 8-hex library/key ids (follow-up 3); her
   published letter's own name (`LETTER.md`, its read-me copy, the seeder literal pinned byte-equal). (An earlier edition
   of this line listed a 13r capture filename as kept too; no ruling covered it — m-2 neutralized it.)

---

## LIVE STATUS

| Item | State | Commit |
|---|---|---|
| record | opened | `d8765d4a8` |
| A | done | `c2c9da936` |
| B | done | `a71e41bac` |
| C | done (four commits) | `1bdee090e` · `ebd18d17f` · `667d481b7` · `0715f81ee` |
| D | done | `c952778e6` |
| E | done (the private repo's own commit `42de8ce` first) | `707684cd2` |
| record | checkpoint | `31a4de4dc` |
| F | done | `696495efa` |
| record | first pass closed | `60bc19258` |
| follow-up 1 | done | `25e1eb602` |
| follow-up 2 | closed as keep (ruled) | — |
| follow-up 3 | done | `a9f6e5d5f` |
| follow-up 4 | done | `c28950d19` |
| follow-up 5 | done (the private repo's commit `d6c2a1d` first) | `b44f3649b` |
| record | follow-up closed | `73d003b5c` |
| cold review (fresh Opus) | NOT MERGE-READY — 1 BLOCKER · 4 MAJOR · 4 MINOR · NITs; the cold-review fixes batch below | — |
| fix B-1 | done | `b15fed578` |
| fix M-1 | done | `02e74d1f4` |
| fix M-2 | done | `4eb7b7a88` |
| fix M-3 | done (the private repo's commit `87c6aa0` first) | `24da5a4a1` |
| fix M-4 | done (same private commit) | `ee6da94d9` |
| fix m-1 | done | `ffe0bf923` |
| fix m-2 | done (the two notes; this record's line in the next commit) | `0269abdda` |
| fix m-3 | done (the private repo's commit `ba2b7ed` first) | `e9c5e72fd` |
| fix m-4(a) | done | `cba065288` |
| fix m-4(b) | done | `84f27c226` |
| fix m-4(e) | done | `f426a653b` |
| fix m-4(f) | done | `9dc9f0a8f` |
| fix m-4(c) | done (the private repo's commit `c1bb6b7` first) | `53c34da4b` |
| fix m-4(d) | done — the relocation, then the two line cuts (the private repo's commit `9d9e308` first) | `d4d3d99e4` · `220ebc285` |
| R-oss-39 | done in two commits (the private repo's commit `4974253` first) | `1c6ace58c` · `7600b5213` |
| NITs | done | `9d7b1d14f` |
| final checks | AccountVaultWireTests 13/13 · walk self-test exit 0 (72 guards) · every unbounded re-grep zero | — |
| record | cold-review fixes batch closed (this text) | this commit |
