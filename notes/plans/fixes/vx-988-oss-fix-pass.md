# VX-988 — the OSS fix pass (HEAD edits from the sweep rulings)

**STATUS: IMPLEMENTED (first pass + her follow-up batch) — branch `vx-988-oss-fix-pass` pushed, NO PR opened (the
orchestrator's call).** Worktree `~/dev/variorum-vx-988`, off `main` at `fd021908c`. HEAD-only: no history rewritten, no
commit message touched.

## FOR A LATER READER

**Not done, first:** the other pile-B rows no ruling put in this pass (e.g. the security-as-roadmap row in
`notes/TICKETS.md`, home and scratch paths) are untouched; a few money mentions outside the files her follow-up named
remain (open item 3); and one first-pass commit message names a removed rider by its class — a message-rewrite rule for
the flip (open item 1). Everything else she ruled is applied below.

**The mechanism.** The open-source sweep (VX-754 — piles A/B/C/P read by agent eyes) flagged sensitive content across the
history and the tree at HEAD; the author ruled every flag (rulings R-oss-N, held on the PRIVATE verdict ledger outside
this repo — the ledger never enters the repo, and this record carries ruling ids, classes and counts only, never a removed
value). This pass is the edit of the working tree at HEAD that applies those rulings, in two rounds: the first pass (items
A–F), then her rulings on its survivors (the follow-up, items 1–5). The later filter-repo rewrite (VX-749) handles every
older version of every file; commit messages, the prompt record and transcripts belong to that rewrite and to the
packaging work, not here. Removed text that had a home to go to went to the private planning repo FIRST (the OSS plan's
"excision is a relocation" rule): the two relocated files, and every passage the follow-up cut.

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
  14a record's spend deliberations (two field-note rounds whole, five sub-bullets or clauses, one figure); the 14c record's
  *[removed for publication]*
  purchase ruling, three embedded figures) and the same in the 14c handoff and gate handoff; the 13n door note's chat
  *[removed for publication]*
  `notes/AppSpecDeltaArchive.md`'s 14C delta (two passages — **a frozen canon archive, edited at her explicit word;
  passages cut only, nothing restructured**; the 14D delta carried none). The removed text is verbatim in the private repo
  (`relocated/oss-fix-pass-removed-passages-2026-11-11.md`, its commit `d6c2a1d`).

**Evidence.** Grep at HEAD after both rounds: every tester token, every scrubbed address, every R-oss-27 token, the
replaced prose and the straggler strings — zero outside the load-bearing files (follow-up item 2). `swift test --filter
AccountVaultWireTests` 13/13 green and `Tools/WalkKit/first-run-walk.sh --self-test` exit 0 (72 guards), after each
round. The app-target test files changed only by a string literal or a comment (not run: an `xcodebuild test` needs a
stage claim).

**Open items:**

1. **A first-pass commit message names a removed rider by its class** (item D's, `c952778e6`) — no value quoted, but it
   names the class. History is never rewritten here: VX-749 needs a `--replace-message` rule for it.
2. **Kept on purpose, all ruled:** the load-bearing values (follow-up 2); the 8-hex library/key ids (follow-up 3); her
   published letter's own name (`LETTER.md`, its read-me copy, the seeder literal pinned byte-equal); a capture filename in
   the 13r record that carries the walk account's display name (renaming it points at nothing).
3. **Money mentions outside the follow-up's named passages** (found while cutting; nothing ruled on them): a figure in the
   master plan's 14d row; a few in `notes/PhaseCloseoutArchive.md`, `notes/fragments-bridge-contract.md` and
   `notes/plans/phase-14d-fragments-batch.md`; the 14a record's "$0 road" labels on an engineering variant; the 14c record's
   *[removed for publication]*
   messaging. One more decision if she wants them gone.
4. Other pile-B H rows outside this pass (e.g. the security-as-roadmap row in `notes/TICKETS.md`, home and scratch paths).

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
| fixes m-1 … m-4, R-oss-39, NITs | in progress (next: m-1 wording) | — |
