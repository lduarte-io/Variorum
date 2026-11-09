# VX-915 — ladder round 2 (cold review, opus-reviewer)

*Scope: the round-1 fix commits ONLY — 2da23f859 · 9e75a2e91 · 3fd1e15e6 · fbc8227a0 · 9278aa6f7 · f6239124f · 955d35bc0 · e94ad51d7 · 9f8502462 · 3c04ac0c8 · 375e5c5ac · e2d803af3 · de0c578fd on `vx-915-recents-sweep` (the origin/main merge 795bb7148 and the later handoff commit aff78616f are out of scope). REVIEW_PROMPT.md verbatim; anchor = round 1's findings (`vx-915-ladder-round1.md`) and the record's THE LADDER section. Every mechanism below was traced by this reviewer at the file:line given. No subagent was used. No `xcodebuild` of any kind; two small filtered headless runs (listed in the clean bill).*

## Scope note

No Fable-mandatory seam. The union of the 13 commits' files is the quick-note pad and band (`QuickNoteView.swift`, `QuickEntryBar.swift`, the new `Core/Views/CaptureLanding.swift`), the MCP tool and its copy (`MCPToolCatalog.swift`, `MCPWriteTools+UnlinkVersions.swift`, `MCPPaneCopy.swift`), one whitespace line in `CapabilityRegistry.swift`, comment lines in `CompareBoardView.swift`, tests, and the record. Nothing in `Sources/VariorumCore/Sync/`, `Protection/`, custody or keychain code, nothing in `PaneSurface`/`EditorTextView`/`BlockRangeIndex`/the read tier, and no change to a default's meaning.

## Findings

### BLOCKER

None.

### MAJOR

None.

### MINOR

**R2-1 [MINOR — words/design, her bundle] · `App/Variorum/Variorum/Features/MCP/MCPPaneCopy.swift:1851-1855` (Fix 1, 375e5c5ac) + `line()` at `:1673-1704` · For ordinary titles the unlink receipt still says "made a change". The fix moved the threshold but did not close the class gate36 traced.**
- **Mechanism (traced, counted by this reviewer):**
  1. `line()` composes `client + " " + phrase + " · ⌥⌘Z undoes"` and, past `budget` (72), falls to the count line. No title-dropping short arm exists for `.versionUnlink` (`:1677-1701` has them only for `.wingMove`, `.wingCopy`, `.duplicate` and `.bookDelete`).
  2. The mirror's fixed part is 55 characters at an 11-character client name ("claude-code", "variorum-de"). So the two titles may total at most 17 characters.
  3. The wire suite's own pair, "draft one" and "draft two" (`MCPUnlinkVersionsServerTests.world`, `:61-62`), gives "claude-code unlinked “draft one” and “draft two” as versions · ⌥⌘Z undoes" = **73 > 72**. The line therefore reads "claude-code made a change · ⌥⌘Z undoes".
  4. For the SAME pair, `.versionLink`'s line is **71** and shows whole. So linking a pair names both notes and unlinking it says "made a change". The "mirror" is 2 characters longer ("un"), so it does not mirror at the budget edge.
  5. Her own pair from the ticket ("day 42" / "V97") gives 64 and fits. The one-note form fits up to 15 title characters ("…inside “draft one”" = 66).
- **Why it matters:** gate36's trace named the defect as "the ruled receipt never displays its words for any real pair". After Fix 1 that sentence is still true for most real pairs (two ordinary titles of 9+ characters each). The disposition accepted "versionLink's own long-title fallback class", but the unlink's class is strictly wider than the link's.
- **Proposed fix (her words, her bundle):** one title-free arm before the count fallback, on the house precedent at `:1683-1693`, where Open › already carries the pair. For example: `if run.count == 1, first.act == .versionUnlink { short = "\(client) unlinked two notes as versions\(tail)" }` (55 characters), with the one-note analogue "removed a version link". Or shorten the phrase itself (dropping " as versions" lets the titles total 29).
- **Pin (an Improvement pin of the new contract, red on the current tree):** `MCPReceiptCopy.line([receipt(.versionUnlink, title: "draft one", detail: "draft two")]) != "claude-code made a change" + undoes`, plus the exact short form she picks. This is not bug-class: the count fallback is designed behaviour. The orchestrator may record it for the bundle only.

**R2-2 [MINOR — closeout completeness, the round-1 F-4 class] · run record `vx-915-recents-sweep.md:352` (batch 3's canon delta), `:554` (batch 6's walk evidence), `:517`/`:535`/`:557` (batch 6's faces and PROVISIONAL list) · The owed canon text and the closing walk's expected words are now stale against what the fix round shipped.**
- **Mechanism:**
  1. The batch-3 SurfaceContracts delta still says the redirected capture "lands **bookless** wearing that wing's own quicknote tag". F-1's own premise, pinned by `QuickNoteWingLandingTests.aCaptureABookInThatWingSeatsNamesTheBookNotThePool` with the premise green at gate36, is that a living W book whose rule is W's quicknote tag SEATS it. The receipt now names that book (`QuickNoteView.swift:605-609`). Applied as written at the merge, the canon sentence would be false for exactly the case this round fixed.
  2. Batch 6's NOT DONE line (`:554`) tells the closing walk to look for "her receipt line ("…removed the version link between “A” and “B”" …)". After Fix 1 that line no longer exists. The walk will see "‹client› unlinked “A” and “B” as versions", or "‹client› made a change" (R2-1), for any pair of ordinary titles.
  3. The PROVISIONAL list at `:557` still offers her the superseded "removed the version link between…" words.
  4. The orchestrator's verification block (`:642`) and G1 (`:651`) carry the new words, so the record contradicts itself.
- **Proposed fix:** amend the batch-3 delta, e.g. "…lands in that wing wearing its own quicknote tag, bookless unless a living book there collects that tag; the receipt names where it landed (`CaptureLanding`, the band's rule)…". Re-word `:554`'s expected receipt and `:557`'s list to the shipped words: the mirror, the "inside “A”" one-note form, and the F-1 landing forms. W-841 (`:337`) could gain the seated arm as one more walk step. Outside this round's commits, the handoff draft (aff78616f, `notes/handoffs/vx-915-handoff.md:19`) repeats "lands bookless". No pin owed.

### NIT

**R2-3 [NIT — coverage, a guard, not a bug pin] · `Sources/VariorumMCP/MCPWriteTools+UnlinkVersions.swift:137` · Only one arm of the new `oneNote ? nil : titles[notes[1]]` is pinned.**
- The copy now reads `detail == nil` as "a link inside one note" (`MCPPaneCopy.swift:1853-1855`).
- The wire round-trip test checks only `act`, `targetID` and `show` on its receipt (`theIDLinkVersionsAnsweredUnlinksAsOneUndoAndRoundTrips`, `MCPUnlinkVersionsServerTests.swift:145-147`).
- So a regression to `detail: nil` on every path would make every two-note unlink say "removed a version link inside “A”" with every pin green. Only F-7's one-note arm is guarded (`:211`).
- Add one line to the round-trip test: `#expect(receipt.detail == (stored.noteIDs[1] == w.a.id ? "draft one" : "draft two"))`.
- Honest label: the code is correct today, so no red-on-old pin exists. This is a guard.

**R2-4 [NIT — hazard] · `App/Variorum/Variorum/Features/QuickNote/QuickNoteView.swift:703` · `filedInWing(_:books: [String]? = [])` defaults to the over-claim F-1 closed.**
- A future caller that omits `books:` gets "Filed in the Pool of “W”" again without reading anything.
- The default exists only for two test lines (`QuickNoteWingLandingTests.swift:116, 205`). The one product caller passes the read.
- Drop the default and have the tests pass `books: []`. No behaviour change.

**R2-5 [NIT — cleanliness] · `App/Variorum/Variorum/Core/Views/CaptureLanding.swift:6-13` vs `Core/Views/NoteDuplicate.swift:50-53` · "The rule exists once" is partial.**
- `NoteDuplicate.run` keeps a verbatim third copy of `CaptureLanding.books`'s read (`readingsContaining … .filter { $0.kind == .book } .map(\.name)`).
- `DuplicateCopy.landed` (`:116-126`) keeps the same 0/1/n count switch with its own words.
- `CaptureLanding`'s own doc calls its read "the duplicate's landing read".
- Either route `NoteDuplicate`'s read through the shared helper (and name it for a note's landing, not a capture's), or narrow the header to "both capture doors".

**R2-6 [NIT — traceability] · commit 9f8502462.**
- The commit is labelled F-9 ("TRACED AND STOPPED … no code changed", "Part of VX-841"), yet it carries a VX-943 test edit: the rung comment in `MCPDoorErgonomicsFacesTests` made one literal.
- Canon cites SHAs, so a later reader bisecting VX-943's faces will not find that edit under its ticket.
- The orchestrator has already noted the commit's unverified compiler claim (`:640`). Record-only.

**R2-7 [NIT — record currency] · run record THE LEDGER (`:663-671`).**
- Rows 6–8 still read PENDING(gate34), and rows 9–11 and 14 PENDING(gate36).
- The record's own GATE36 RAN section (`:583-592`) shows the red legs watched (VX-928's five, F-1's one) and 71/73 green, with the two reds fixed and pending gate36b.
- Update the ledger at closeout.

## Clean bill (checked by this reviewer, found solid)

- **F-1 (9e75a2e91):**
  - The band's four words are byte-unchanged through `CaptureLanding.place`: "Filed in " + "the Pool" + "." and so on, pinned at `QuickEntryFileWithoutOpeningTests.swift:221-224`, with the seated case at `:298-313`. The band's read moved verbatim.
  - The pad's W arm reads after the runner turn, in the same intake transaction that seats.
  - `readingsContaining` lists BOOK rows with `status = 'member'` only (`ShelfQueries.swift:664-674`). So an arrival (a bell) and a W gathering both leave the note honestly in "the Pool of “W”".
  - Home's arms read nothing extra.
  - The `try?` read gives the band's nil posture ("Filed — tagged #quicknote.").
  - gate36 watched the red leg at exactly its two receipt lines, with the premises green, and then the green on the fixed tree.
- **F-8 (e94ad51d7):** `Queries.liveWing(db, id:)` is exactly `wings(db).first { $0.id == id }` (both read `deleted_at IS NULL` by id, `WingQueries.swift:105-116`). The `wingID.isEmpty` guard keeps the Home fast path read-free.
- **F-3 (3fd1e15e6):**
  - The description claims no authorship.
  - Edge ids reach the wire only through `link_versions`' answer: grep over `Sources/VariorumMCP` finds one producer, `MCPWriteTools+LinkVersions.swift:114`.
  - The rung and the saved-version sentences are still said.
  - The `TutorialMCPChapterTests` justified edit pins substrings that are actually present.
  - The pin is red on old by construction (3 issues, matching the record).
  - The "her words" strikes are accurate at all three sites. The remaining "her relay" phrasing correctly names what she relayed.
- **F-7 (f6239124f → 955d35bc0):**
  - The one-note test reads the in-transaction ends (`unlink.ends.noteIDs`).
  - The answer's `note_ids` is unchanged.
  - The trail's `placeTitle` reads `targetTitle` for this act (the default arm, `MCPTrail.swift:344-352`), so it is unaffected by `detail` going nil.
  - `titles` holds a non-optional `DisplayTitle.note` for every note past the read-first gate, so `detail == nil` arises only for one note.
  - The pin is red on old by construction (`detail` was "draft one").
- **Fix 1 (375e5c5ac) arithmetic,** recounted independently: 61 (mirror at "one"/"two"), 60 (one-note), 48 (count). The threshold is 17 title characters. Her ticket's pair is 64.
- **Fix 2 (e2d803af3):** strengthened, not weakened.
  - The joined line is checked through `Queries.joinRenderedTexts` by name.
  - The new `[String?]` row-level line (`renderPost` ordered by `(position, id)`, `PostRender.swift:159`) also catches gaps and empty slots that `renderedText` skips.
  - The seeder mints one `newBlock` per paragraph (`TutorialSeeder.swift:595-606`). No product line changed.
- **F-5 / F-6:** `applyCallout`'s doc is byte-identical to `5b7452877^` (`:1163-1168` there, `:1193-1198` here) with nothing left orphaned. `takeFamilyPlusCompare: @Sendable` is restored.
- **Pin-before-fix order:** `2da23f859` → `9e75a2e91`, `f6239124f` → `955d35bc0`, by timestamp and content.
- **Trailers and invariants:**
  - Zero `Co-Authored-By`/`Claude-Session` trailers on all 13 commits.
  - No word-level tracking, no cross-entity text copy, and no corpus-scaled read. `readingsContaining` is ∝ the note's rows plus the library's gatherings, the band's and duplicate's accepted posture.
- **Ran (headless, filtered, per the machine rule):**
  - `swift test --filter "MCPUnlinkVersionsServerTests|MCPProviderNeutralityTests"` → "Test run with 14 tests in 2 suites passed" (the VX-943 suite 12/12).
  - `swift test --filter "MCPWireNeutralityTests|MCPDocsTailTests|MCPLinkVersionsServerTests"` → "Test run with 12 tests in 3 suites passed".
- **Not verified by this reviewer (stated, not assumed):** the Mac-target compile and run of Fix 1's and Fix 2's edits. Both are gate36b's; they were read here and look type-correct against the shapes gate36 already compiled.
