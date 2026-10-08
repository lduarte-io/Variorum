# VM-5 ladder round 1 — the RESOLUTION review (cold, Fable)

*Reviewer: a fresh cold session, 2026-10-07, running `notes/REVIEW_PROMPT.md` verbatim over
`git diff dd7cad84..HEAD` in `~/dev/variorum-vm-5`, with both parents in view
(`dd7cad84` = origin/main · `28ee417a` = the mobile tip · merge base `43a35ef8`).
Method: reconstructed git's own clean auto-merge (`git merge-tree --write-tree` →
`dead5e47…`) and diffed HEAD against it, so every HAND decision — the 13 conflict
resolutions plus all fix-ups — was reviewed as one explicit diff, and every
auto-merged both-sides file was classified and eyeballed against both parents.*

## Findings

**[MINOR 1] · `App/Variorum/VariorumMobile/Features/Shell/MobileListingFilters.swift:99–115`,
`Features/Shell/MobileLibraryViewModel.swift` (the union doc's Archive-room clause),
`Features/Shell/MobileShelfFaces.swift:154` · Three merged-in comments assert a model fact
that 13i-e falsified — and one of them argues the owed work is impossible.**
Mobile-era comments state, as a MODEL FACT: *"`reading` carries no `archived_at` … A book
finishes or is deleted; it never archives. An Archive 'books' door could never have content —
… no future row could arrive without a schema change"* (ListingFilters), *"`reading` carries
no `archived_at`, so nothing but a note can be archived"* (LibraryViewModel), and *"the phone
has no Archived surface yet"* (ShelfFaces — the phone has had one since batch 6c; it is
notes-only). On the merged tree the schema change HAPPENED: `Reading.archivedAt` exists
(`Sources/VariorumCore/Models/Reading.swift:77`), `Operations+ReadingArchive.swift` exists,
and the phone's own merged shelf long-press ARCHIVES the daily Journal
(`MobileShelfView.swift:337` → `ops.archiveReading`). Evidence of the concrete degradation:
her 2026-10-04 live walk (recorded at `notes/MobileSoul.md` line 254) — an archived book
vanished from the phone's every surface and she mistook the hidden state for a sync bug,
*"precisely because the BOOKS group is still owed here."* The behavioral gap itself is OWNED
(MobileSoul's 13i-e row, F-U1-4 — the catch-up builds the Archived BOOKS group + unarchive),
so it is NOT a finding; what is a finding is that the next session building that owed face
will meet three comments telling it the face "could never have content." Comment class — no
pin owed. **Fix:** correct the three comments to today's fact and point each at the owed row
(MobileSoul F-U1-4 / the 13i-e row).

**[MINOR 2] · `App/Variorum/VariorumMobileTests/MobileStructuralTests.swift:1119–1121`
(the `MobileNoRedirectSweepTests` Jekyll exemption) · The exemption is HONEST in substance,
but its PREFIX shape exempts the whole literal — including anything added to it later.**
Judged as the brief asked. Honest: the Jekyll `aboutThisBook` copy
(`App/Variorum/Shared/SampleLibrary/SampleLibraryJekyllBook.swift:91`) names the Mac's
Help ▸ Restore because that door exists only there today; the phone's restore door is owed
and named (PL-17 / VM-8); editing `Shared/` was outside this effort's fence, so an exemption
was the right instrument; the retirement condition is written at the exemption. The prefix
mechanics are correct against the extractor (verified: the state machine strips backslashes —
`\u{201C}` → `u{201C}` — and keeps the multiline literal's real newline + indent, so
`"\n        u{201C}The Strange Case of Dr Jekyll"` matches the compiled extraction; the suite
ran green BY NAME in this review's own run). The weakening: the two pre-existing exemptions
are EXACT-literal, so any change to the exempted string re-trips the walk — this one is
`hasPrefix`, so a FUTURE Mac-naming sentence appended inside `aboutThisBook` passes the sweep
silently. Bounded (one literal, one file, a named retirement), hence MINOR. **Fix:** keep the
prefix but add a one-match cap to the exemption arm — e.g. exempt only when
`literal.matches(of: Self.forbidden).count == 1` — so the known mention passes and a second
one trips. (A pin exists by construction: add a second "Mac" to the literal in a scratch run
and the sweep must go red.)

**[MINOR 3] · `notes/handoffs/vm-5-handoff.md` ("What happened") · The handoff states the
branch retirement as done; the tag does not exist.** *"the long-lived `mobile` branch is
retired behind tag `archive/mobile-2026-10`"* — `git tag -l 'archive/mobile*'` is empty and
`mobile` + `origin/mobile` both still exist. The Verification section is honestly marked
PENDING, but this narrative sentence is a present-tense claim a reader (or she) would trust.
Record class — no pin. **Fix:** either word it as the close step it is ("retires at the PR
behind tag …") or ensure the close choreography creates the tag before the handoff ships.

**[NIT 1] · `notes/QUESTIONS.md` §"Mobile Round 2 — RENUMBERED" · Frozen mobile-era records'
old citations now resolve to DIFFERENT live entries.** The renumber itself is clean (verified:
zero duplicate numbers; exactly eleven entries #189–#199; main's #84–#188 intact; the next-free
marker corrected to #200 at the true file end; the mapping key present with the frozen-records
policy stated). The residue: a reader chasing a mobile-era record's "#84"/"#89" lands on
main's unrelated-but-plausible entries (mobile's old #89 vs main's #89 — BOTH touch the
bridge/round) unless they know to consult the key. Policy-accepted; recorded so round 2/3
readers know the key is load-bearing. Optional: a one-line "old numbers resolve through the
VM-5 key" banner at the head of the two most-consulted mobile records.

**[NIT 2] · `App/Variorum/VariorumMobile/Features/Write/MobileEditorViewModel.swift:1456`,
`Features/Shell/MobileLibraryView.swift:432` · Two merged comments name retired/unreachable
things.** The B45-2 comment names `CrossBlockEditPlanner`, replaced by `CrossBlockCompound`
at 13u1 (the old name survives only in two historical comments in `Shared/EditorBrain`); the
carried-across empty-state comment says the widened guard matters "under `.books`/`.all`" —
`.books` renders through `bookRows` (`MobileLibraryView.swift:76–78`) and never reaches
`listingRows`, so only `.all` is live there. Comment precision only.

## Clean bill (checked and found solid)

1. **Confinement + the two discharge arguments.** `git diff --name-only dd7cad84..HEAD` is
   exactly `App/Variorum/VariorumMobile/**` + `App/Variorum/VariorumMobileTests/**` +
   `notes/**` — zero `Sync/`, zero `Shared/`, zero `Sources/`, zero schema, zero pbxproj
   (re-derived, not trusted). The pbxproj's `fileSystemSynchronizedGroups` map the Mac target
   to `Variorum` + `Shared` only and `VariorumTests` to its own folder — so the Mac target's
   and core's inputs are byte-identical to the tree 17y closed green. **The Mac-suite
   discharged-by-construction argument is accepted; I do not demand the run.** (Core is
   discharged the same way, and was re-run green anyway.)
2. **No silent side-drops, no resurrections.** A full three-way classification of every code
   file: the ONLY files where one parent's changes were discarded are
   `MobileStarterJournal.swift` + its tests — exactly the record's deliberate call, and
   mobile's three discarded pins all pinned the superseded B1 sync-wait design (verified
   against `43a35ef8..28ee417a`; main's first-write design carries its own pins). No file
   main deleted was resurrected (the bridge's deletions hold; zero bridge symbols
   reintroduced in the mobile target).
3. **`MobileEditorViewModel` (byte-identical to git's clean auto-merge — no hand edits)
   eyeballed at every interleave.** All eight of mobile's `noteIsGone` sites survive
   (grant/adopt/belt/relinquish — same set as the mobile parent); the tombstone belt sits
   FIRST in the merged `shouldChangeText`, above main's 18m `EditorEditRoute` table, so the
   more specific refusal still wins; mobile's B45-2 by-identity slot write, the M23≡R15
   displayed-text copy projection, `saveVersion`, and the `DeletionRefusal` forwarding all
   composed intact beside main's conductor band, clamp road, and route arms. The one hazard I
   chased — a pre-deletion tail idle-mint firing into a tombstoned note under the merged
   crystallizer — is HOLLOW: `Operations.newBlock` resolves `liveContainer` and throws
   `containerNotFound` (`Operations+Container.swift:57`), identically on both parents; a pin
   would pass on both sides.
4. **One rule per gesture survives the merge.** Exactly one divide brain
   (`KeepOnTopDivide.compose` — U-2's ruled phone shape) and one merge join
   (`MergeJoinRule.door`) on the merged phone; zero residual `divideDuplicating` /
   `MergeJoin.canon` call sites. 13i-e's archive-not-delete rule is honored at EVERY merged
   book-delete door (`offersArchiveInsteadOfDelete` guards the shelf long-press AND
   BookDetails; the Library's union bookRow deliberately carries no acts).
5. **The hand-resolved semantic widening (MobileLibraryView) is correct.** The Act-0 empty
   state's guard now also requires `shelved.rows.isEmpty`; under `.notes`/`.bookless` the
   books half is `[]` by construction (main's original condition restored), under `.all` the
   union's books really gate it, and `.books` never reaches the guard. Main's EmptyStore
   tests were moved onto the union signature with assertions preserved.
6. **The test-side fix-ups are faithful, not weakened.** The sort pins now compose
   `MobileLibraryViewModel.sortWord(…)` → `LibrarySortWords` — the right level: the pins'
   subject is the door-re-speaks mechanics, while the WORDS are her R-Q8 ruling held in the
   one shared home with its own composition pins (`MobileLibraryTests:316,325`), and the
   hand-added `.title` arm is honestly unreachable (`setSort` guards `.title`; `sortOptions`
   omits it). The Row-across-async rewrites (BlockMenu/Versions tests) and `@MainActor`
   annotations preserve every assertion byte-for-byte in meaning.
7. **The notes unions hold both histories.** MobileSoul: PL-9 kept as history with main's
   dissolution note; PL-10 kept mobile's corrected cell (her severity correction intact);
   PL-14 flipped CLOSED with the batch records named; PL-11 keeps its owed (f); PL-25
   deduped to PL-25b; PL-3 flipped DELIVERED; the §5 truth-9 drag rider landed. The
   orchestrator handoff keeps main's 2026-09-02 pointer AND mobile's §12.2.
   `MobileLivenessTests` union arithmetic is exact — base 7 + main's 1 (P26) + mobile's 10
   (4.5c) = 18 `@Test`s at HEAD, and **all 18 ran green by suite name in this review's own
   targeted run** (with `MobileNoRedirectSweepTests` and `MobileStarsTests`: 23 tests /
   *[removed for publication]*
8. **The QUESTIONS renumber** — verified collision-free end to end (finding NIT 1 covers the
   one residue). **The obligations table** — #3 (ledger flips present as claimed), #10
   (renumber), #13 (zero Mac-reaching files) spot-verified true.
9. **Vocabulary drift checked and not created here:** the phone's user-facing "smart book"
   strings (merged lesson, membership chip) match MAIN's own current phone copy
   (`MobileCreateBook`, `MobileTodayDoor` — untouched main files); "gathering" is Mac-side
   user-facing only. The phone's word catch-up is 13i parity work, not merge drift. The
   tutorial lesson's star cap was corrected to the merged truth ("up to fifteen" =
   `Operations.starLimit`).

## Disposition slots (the orchestrator's, per the cross-model/same-model flow)

| # | severity | disposition |
|---|---|---|
| 1 | MINOR | |
| 2 | MINOR | |
| 3 | MINOR | |
| N1 | NIT | |
| N2 | NIT | |

---

## DISPOSITIONS (orchestrator, 2026-10-06 — same-model flow; 0B/0M closes the round with one wave + verification per the established ladder rule)

| finding | disposition |
|---|---|
| MINOR 1 (three stale model-fact comments) | **FIXED** — all three corrected to the merged tree's facts, each pointing at the owed face (MobileSoul 13i-e row / VM-6 (4d)); comment class, no pin owed |
| MINOR 2 (prefix exemption exempts the whole literal) | **FIXED + RED-VERIFIED** — the exemption now also requires exactly ONE forbidden occurrence in the literal; a scratch second "Mac" sentence injected into the Jekyll literal tripped the sweep (TEST FAILED), the file restored byte-exact (cmp-verified, `Shared/` clean), the clean tree green by suite NAME |
| MINOR 3 (handoff claims an un-cut tag) | **FIXED** — reworded as the close-choreography step it is |
| NIT 1 (old-number citations in frozen records) | **FIXED** — the NUMBER KEY banner added to the two most-consulted records (the orchestrator handoff, the 09-01 status file) |
| NIT 2 (two stale comments) | **FIXED** — the planner name updated to `CrossBlockCompound`; the empty-state guard comment now says only `.all` is live |

Wave verification: targeted suites green by suite name (28/3 incl. the no-redirect sweep and the structural suite); zero production-behavior changes in the wave (comments, one test guard, docs).
