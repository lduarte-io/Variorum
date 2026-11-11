# VX-988 — the OSS fix pass (HEAD edits from the sweep rulings)

**STATUS: IMPLEMENTED — branch `vx-988-oss-fix-pass` pushed, NO PR opened (the orchestrator's call).** Worktree
`~/dev/variorum-vx-988`, off `main` at `fd021908c`. HEAD-only: no history rewritten, no commit message touched.

## FOR A LATER READER

**Not done by this pass, first** (each is outside the brief's six items, or an occurrence the rulings leave ambiguous —
left untouched on purpose, listed for the orchestrator; details under "Open items"): the author's own addresses at HEAD
(the R-oss-12 class); identifier occurrences that are the shipped app's or a guarded tool's working identity; identifier
*[removed for publication]*
live inside other files.

**The mechanism.** The open-source sweep (VX-754 — piles A/B/C/P read by agent eyes) flagged sensitive content across the
history and the tree at HEAD; the author ruled every flag (rulings R-oss-N, held on the PRIVATE verdict ledger outside
this repo — the ledger never enters the repo, and this record carries ruling ids, classes and counts only, never a removed
value). This pass is the ONE edit of the working tree at HEAD that applies those rulings. The later filter-repo rewrite
(VX-749) handles every older version of every file; commit messages, the prompt record and transcripts belong to that
rewrite and to the packaging work, not here.

**The edits, by work item** (one commit per piece; every commit message describes the edit mechanically):

- **A · R-oss-11 — tester identity** (`c2c9da936`). Names, handles and addresses of the two beta testers become
  **tester A / tester B** where one passage needs both apart (the vx-494 and vx-510 records, the vx-510 kickoff and
  handoff, `notes/AppSpecRecord.md`, `notes/PhaseCloseoutArchive.md`) and **the tester** where only one appears (the
  vx-440, vx-500, vx-529, vx-601 records and handoffs, the vx-601 ladder round, four code comments in
  `EditorTextView.swift`, `CapabilityRegistry.swift`, `CaretPress.swift`, `CaretPressTests.swift`). Addresses removed
  entirely; where a name sat INSIDE her verbatim quote it is bracketed (`[tester A]`). Their quoted words stay. The 13r
  walk's scratch macOS account (a handle in the same token family — no person) becomes **the test account** /
  `<test-account>` across the 13r record, its orchestrator handoff, the 13r handoff and two closeout-archive lines.
  22 files.
- **B · R-oss-20 — the 14b re-key suite email** (`a71e41bac`). The runbook file itself is already gone at HEAD (removed
  at the 14b closeout, history only); its executed drill step in `notes/plans/phase-14b-suite-e2ee.md` (THE WIPE AND
  REPUSH, step 6) carried the suite account's address — redacted to "(the address redacted)". 1 file.
- **C · R-oss-25 — the personal class** (four commits):
  - `1bdee090e` — `notes/plans/use-report-2026-09-06-mockups/ceremony-and-note-box.html`: every sample take text
    (13 lines across figures A, B, D) replaced by invented prose of similar length (a hiking entry). Every mockup/HTML
    file re-grepped for the replaced sentences: none elsewhere.
  - `ebd18d17f` — the two 18l screenshots `notes/plans/18l-inputs/2026-09-25-write-{before,after}-removing-newline.png`
    removed; their three references (`phase-18l-navigation-feel.md`, `post-13u-health-rounds.md`,
    `WriteTopAirTests.swift`'s header comment) now say the captures were removed for publication.
  - `667d481b7` — `notes/source/author-intake-2026-07-25.md` trimmed to its Variorum sections: the four personal
    sections removed, the line `*[personal sections removed by the author for publication]*` at the cut, everything
    from "Items I want for Variorum:" on byte-identical.
  - `0715f81ee` — the family aside out of `pre-13u-memo-security-shapes.md`'s §8a heading; the relationship clause out
    of the quoted threat model in its three copies (`phase-13p-note-protection.md`, `vx-266/cold-read-1.md` and
    `.html`), marked `[…]`, the technical point intact.
- **D · R-oss-26 — the OSS plan's own riders** (`c952778e6`). `notes/plans/open-source-readiness.md`: the ruled rider
  sentences at the end of checklist item 3 (with their context) and the ruled her-hands rider line under item 5
  removed; the rest of the plan unchanged. 1 file.
- **E · R-oss-23 — two files relocated** (`707684cd2`). `notes/release-and-v1-strategy.md` and
  `notes/marketing-launch-approach.md` copied verbatim into the private planning repo's `relocated/` (its own commit
  `42de8ce`, pushed) and then removed here; the 31 references across 18 notes keep the file name and say "(relocated to
  the private planning repo)".
- **F · R-oss-27 — identifiers** (`696495efa`). Angle-bracket placeholders naming the kind: `<apple-team-id>`,
  `<apple-cert-id>`, `<signing-cert-sha1>`, `<notary-key-id>`, `<supabase-project-ref>` (all three refs at HEAD),
  `<device-udid>` (the physical devices), `<account-uuid>` (eleven account ids/prefixes — hers, the testers', the test
  and probe accounts), `vmk1_<dev-key-prefix>…` (22 real dev setup-key fragments). 93 files: notes, one test doc comment,
  one walk self-test fixture line. Four test fixtures that carried a real account id
  (`AuthSessionTests`, `KeychainOffMainTests`, `OneRefreshAuthorityTests`, core `AccountVaultWireTests`) now carry the
  fictional `a0000000-0000-4000-8000-000000000001` (a fixture must stay UUID-shaped; the replacement is consistent per
  file). Bundle ids untouched everywhere (her exception).

**Evidence.** The per-token grep at HEAD after the pass: every tester token (unbounded) zero; every R-oss-27 token zero
outside the load-bearing files listed below. `swift test --filter AccountVaultWireTests` 13/13 green;
`Tools/WalkKit/first-run-walk.sh --self-test` exit 0 (72 guards). The app-target test files changed only by a string
literal or a comment (not run: an `xcodebuild test` needs a stage claim).

**Open items** (for the orchestrator; nothing here was edited):

1. **The author's own addresses at HEAD** — the R-oss-12 class, not one of this brief's items: her signing-identity
   address (4 files), her other personal addresses (≈20 lines in the 13r, 14a, 14c, 14d records, the SMTP runbook, the
   14d handoff) and the vxtest test-account address shape (4 files). One more pass, if the orchestrator rules it in.
2. **Load-bearing identifiers left** (replacing them breaks the shipped app or a guarded tool; the value is the app's own
   identity the same way the bundle ids are): the production project ref in `App/Variorum/Shared/ProjectConfig.swift`
   and pinned in `Tools/prod-read.sh`, `Tools/prod-confirm-test-user.sh`, `Tools/prod-reset-test-account.sh` (an env
   read would weaken their pin — the guard the standing reset exception rests on); the team id in
   `project.pbxproj` (DEVELOPMENT_TEAM ×16) and `ProtectionKeychain.swift`'s keychain-group prefix; the team id, signing
   cert SHA-1 and provisioning-profile UUID in `Tools/Release/ExportOptions.plist`; the team id in
   `Tools/Release/verify-export.sh`. Options if her ruling wants them gone: derive the scripts' ref from
   `ProjectConfig.swift`; render ExportOptions from a private env file in `release.sh`. Her call — the team id and the
   prod ref stay public in the app itself either way.
3. **Identifier kinds no ruling names, left:** the provisioning-profile UUID (2 notes), the Supabase ORG id (1 file),
   the OAuth client id (6 files), an auth identity id (2 files), simulator UDIDs (≈80 lines), dev-library UUIDs in prefs
   keys.
4. **"Dev key prefixes" read narrowly:** applied to real setup-key fragments (`vmk1_` + characters). The 8-hex
   library/key ids in walk logs ("library … under …", "key …" — ≈138 occurrences in 26 files, including her real
   account's corpus/Apple key ids) are left: the sweep itself called them out as needing ONE uniform ruling
   (ids-not-secrets vs every truncated key id) and none is recorded.
5. **Ambiguous single hits, left:** a capture FILENAME in the 13r record and its handoff that carries the walk
   account's display name (12 lines — renaming it would point at a file that does not exist); that same display name in
   her published letter (`LETTER.md`, its read-me copy, the seeder literal pinned byte-equal to it) — the letter is
   public by her hand, not a tester; the on-screen journal line the deleted screenshots showed, which also lives as test
   fixture text in `WriteTopAirTests.swift` and in `phase-18l-navigation-feel.md` (R-oss-25 named the images); a note
   title in `notes/author-reports/2026-09-06-use-report.md:41` matching one replaced mockup sentence (R-oss-25 named the
   mockup/HTML files); the intake's provenance comment still says sections 1–4 are preserved and names their topics.
*[removed for publication]*
   *[removed for publication]*
   *[removed for publication]*
7. Other pile-B H rows outside this brief (e.g. the security-as-roadmap row in `notes/TICKETS.md`, home paths and
   scratch paths) — untouched.

---

## LIVE STATUS

| Item | State | Commit |
|---|---|---|
| record | opened | `d8765d4a8` |
| A | done | `c2c9da936` |
| B | done | `a71e41bac` |
| C | done (four commits: mockup prose · the two screenshots · the intake trim · the two redactions) | `1bdee090e` · `ebd18d17f` · `667d481b7` · `0715f81ee` |
| D | done | `c952778e6` |
| E | done (the private repo's own commit `42de8ce` first) | `707684cd2` |
| record | checkpoint | `31a4de4dc` |
| F | done | `696495efa` |
| record | closed (this text) | this commit |
