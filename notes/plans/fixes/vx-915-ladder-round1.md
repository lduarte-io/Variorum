# VX-915 — ladder round 1 (cold review, opus-reviewer)

*Diff under review: `git diff e6b88acb1..HEAD` on `vx-915-recents-sweep` (HEAD `71c8af4d2` at review start). REVIEW_PROMPT.md verbatim; zero framing. Severity-ranked. Every mechanism below was traced by this reviewer at the file:line given; one external fact (Supabase's password-change behaviour, F-10) came from one Sonnet lookup, quoted in place.*

## Scope note (read first)

- **No Fable-mandatory seam by file.** `git diff --name-only` holds no `Sources/VariorumCore/Sync/`, no `Protection/` code (the two `*Protection*` paths are guide text quoting `ProtectionWords`, plus its pin), no custody or keychain code, and no `PaneSurface` / `EditorTextView` / `BlockRangeIndex` / read-tier line. VX-782's pin READS `PaneSurface` geometry. Its fix is SwiftUI chrome in `TakesCalloutFrame` and `TakesBoardView.commentGutter`.
- **One "default's meaning" item for the orchestrator to classify (F-2).** VX-934 changes what a STORED `ownership_badges = "0"` means. Before this diff it hid the Private eye (VX-831/D-831-3; the row's own help said so). After it, the eye comes back under a new key that defaults ON. Her #269 ruling ordered the split, so the new meaning is ruled. What happens to a store that already holds "0" is not ruled. If the orchestrator counts that as default's-meaning content, re-spawn the round as `fable-reviewer`. I reviewed the whole diff either way.

## Findings

### BLOCKER

None.

### MAJOR

None.

### MINOR

**F-1 [MINOR] · `App/Variorum/Variorum/Features/QuickNote/QuickNoteView.swift:593-598` (`QuickNoteMint.file`'s receipt switch) · A quick note aimed at another wing says "Filed in the Pool of “W”" even when a living book in W seated it.**
- **Mechanism (traced):**
  1. The pad's pick W goes to `importPost(…, wingId: W)`, then to the wing-aware `fileAsQuicknote`. That calls `applyTag(W's quicknote tag)` through the one application road (`Operations+Quicknote.swift:105-107`), so a living BOOK in W whose rule collects W's `quicknote` tag SEATS the note. The batch's own pin proves it: `QuicknoteWingTests.aLivingBookInThatWingHearsTheCapture` (`Tests/VariorumCoreTests/QuicknoteWingTests.swift:111-122`, "the applying act seated it").
  2. `fileAsQuicknote` still returns `.taggedOnly`, because `readingID` is nil for every non-Home wing (`:104`).
  3. The receipt arm `case (.taggedOnly, let wing?)` therefore speaks `QuickNoteCopy.filedInWing(wing)`: "Filed in the Pool of “Work” — tagged #quicknote." But the note is a book member, not in the Pool, which is the bookless-notes surface.
- **Why it matters:** this is exactly the over-claim that 13i-b U4's `filedTaggedOnly` / R1-3 comments exist to prevent ("`filedNote` would claim a Quicknotes landing…"). It is reachable in a natural setup: W grows no Quicknotes gathering by her ruling, so making a "quicknotes" BOOK in W is the obvious next step for someone who wants W's captures collected. Home's pre-existing `.taggedOnly` arm (`filedTaggedOnly`, "Filed in the Pool") has the same over-claim. That one is out of this run's reach, but worth a line.
- **Pin (red on the current tree):** a `QuickNoteWingLandingTests` arm where wing "Work" holds a book whose rule is W's `quicknote` tag. Pick W, file, and assert the receipt does not claim the Pool while `Queries.readingsContaining` lists that book. Today that assertion fails.
- **Proposed fix:** take the band's own road (`QuickEntryModel.fileWithoutOpening` reads `Queries.readingsContaining(…).filter { $0.kind == .book }` and names the books through `QuickEntryFileCopy.landed(books:)`). After the mint, read the note's book rows and name the landing: the book or books, else W's Pool. The words go to her bundle beside P-915-B3-1.

**F-2 [MINOR — product silence → QUESTIONS] · `Sources/VariorumCore/Queries/AppearanceQueries.swift:185-186` + `Operations+Appearance.swift:107-118` (VX-934) · A store whose `ownership_badges` is already "0" gets the Private eye back silently after the update.**
- **Mechanism (traced):**
  1. Until this diff, `PrivateMarkFace.note/book(_:badgesOn:)` hid the eye whenever `ownership_badges == "0"`.
  2. VX-905's row, at Settings ▸ MCP's foot, told her exactly that: `badgesSummary`, "One switch for the marks on notes in other books, owned notes and Private ones", now deleted.
  3. After the diff, the eye reads `ai_marks`, which has no row in such a store and so reads ON at READ (`value != "0"`).
  4. So a library where she had turned "Show ownership badges" off to hide the eye shows the eye again, and the shared icon too, which was never switchable before. Her switch now governs only the book marks.
- **What was decided:** the record says "no migration" (batch 1, piece 1) without saying whether stores that already hold "0" were considered. Her ruling is the split. Whether an existing "0" carries over to the new key is not ruled. It is the author's call, not the reviewer's: no carry (as built), copy "0" into `ai_marks` once, or leave it and say so in the release notes.
- **No red-on-old pin applies.** This is a behaviour question, not a bug. Route it to `notes/QUESTIONS.md` in the run's bundle beside F-934-A/B.

**F-3 [MINOR — decision premise] · run record BATCH 6 ("The rung (her words): WRITE NEW on BOTH notes"; the orchestrator's ruling "write new on both at her words") + `Sources/VariorumMCP/MCPToolCatalog.swift:1284-1312` · The rung's cited authority is the agent's request, not her ruling, and the act does not enforce what its description claims.**
- **The premise:** the kickoff quotes the ticket as "her relay of the planetlillian agent's note verbatim". The sentence carrying the rung is the agent's: "It asks for an unlink_versions that takes the ID link_versions already returns, at the same permission level." Treating that as "her words" fixing the rung is not supported. She minted the ticket; she did not rule the rung.
- **The house precedent points elsewhere:** `apply_tag` sits at write new while its opposite `remove_tag` sits at EDIT (MCPSpec, VX-184), and SUGGEST's `delete_comment` reaches only comments on file as the client's own (VX-260). The write-new consent sentence (`MCPPaneCopy.rungDetail(.writeNew)`, `:1210-1220`) says the client can "make new notes, apply tags and build books". It names no removal.
- **The act doesn't enforce "made":** `unlink_versions`' description says "Remove one version link that link_versions made". But `unlinkVersionForClient` accepts ANY live `version_of` edge whose ends resolve, including her own Compare mark. `MCPWriteServerTests` builds exactly such an edge (`hersLink = markVersionOf(...)`) and shows only a SUGGEST client's rung refusal. A write-new client holding that id would land. The only fence is that her edge ids never reach the wire, which holds today: `edge_id` appears only in `link_versions`' answer, and `list_note_lineage` carries none.
- **The fix is a bundle-framing correction, not code:** P-915-B6-1 already lists (a) write new, (b) edit, (c) own-only. The bundle entry should (1) present the rung as an OPEN choice, quoting the remove_tag and delete_comment precedents, never as "her words"; and (2) reword the description's "that link_versions made" until (c) is built, e.g. "a version link, by the edge_id link_versions answered for it", or state the gap.
- No bug-class pin. This is a decision finding.

**F-4 [MINOR — closeout completeness] · run record BATCH 6, "Canon deltas owed" · The owed MCPSpec delta list is missing one enumerated list.**
- MCPSpec's `list_my_activity` sentence enumerates the acts whose refused rows log a looked-up id and so carry no target: "the chapter acts, `delete_take`, `duplicate_note`'s wing side — carries no target (P-VX261-5/6)".
- `unlink_versions` joined that class in code (`MCPOwnActivity.hidesTarget`, `Sources/VariorumMCP/MCPOwnActivity.swift:62-64`).
- The batch-6 delta list names only the contract line beside `link_versions` and lesson 3. Without this addition, canon lags the code. Add it to the closeout's MCPSpec delta. No pin owed.

### NIT

**F-5 [NIT] · `App/Variorum/Variorum/Features/Takes/CompareBoardView.swift:1169-1197` · `applyCallout` lost its doc comment.**
- The VX-793 block (`// MARK: The comments door …`, `commentsRequest`, `requestComments()`, `commentsRequestTaken(_:)`) was inserted between `applyCallout`'s `///` doc comment and `func applyCallout`. That doc ("13c Stage 1 ladder, R2-2 … whichever column it lives in.") now precedes a `// MARK:` line and documents nothing.
- Move the block above the doc comment.

**F-6 [NIT] · `App/Variorum/Variorum/Registry/CapabilityRegistry.swift:104` · whitespace damage.** `takeFamilyPlusCompare:@Sendable` lost its space after the colon. Restore `takeFamilyPlusCompare: @Sendable`.

**F-7 [NIT] · `App/Variorum/Variorum/Features/MCP/MCPPaneCopy.swift:1828-1831` + `MCPWriteTools+UnlinkVersions.swift:131-132` · A link inside one note gets an odd receipt.**
- A `version_of` edge whose two blocks sit in ONE note is reachable: her `moveBlock` re-homes one end. The tool's own comment handles that case ("a link inside one note opens the note").
- The receipt then reads "removed the version link between “A” and “A”", because `detail: titles[notes[1]]` is the same title.
- Say "removed a version link inside “A”" when the two notes are one note. Words to her copy pass.

**F-8 [NIT] · `QuickNoteView.swift:568-571` · A whole-table read where a keyed one exists.** `QuickNoteMint.file` resolves the pick by `Queries.wings(db).first { $0.id == wingID }`. The keyed `Queries.liveWing(db, id:)` exists for exactly this (`WingQueries.swift:111-116`). The table is tiny, so this is cleanliness only.

**F-9 [NIT] · `QuickNoteView.swift:291-293, 307-309` · The face can briefly show Home while the filing goes to W.**
- `landing` reads `wings.wings`, which is empty until the pad's `wings.track()` first answers. A park restore that brings back pick W therefore shows Home's placeholder and no header word for that moment.
- `mintNow` meanwhile files with the raw `pad.landingWingID` (W), resolved against the store. So a ⏎ pressed in that first instant files into W while the face said Home.
- The window lasts one tiny read. Either draw the restored pick's name once the wings load, or hold the placeholder until `track()` has answered once.

**F-10 [NIT — her wording pass] · `App/Variorum/Variorum/Features/Tutorial/TutorialProtectionPassages.swift:51-55` (R1) · The first move is in the weaker order, and half of it is redundant.**
- The recipe says: Sign Out Everywhere, then change the account password at stargazing.tech.
- External fact (one Sonnet lookup over supabase/auth master): `UserUpdate` → `UpdatePassword(tx, sessionID)` ends with `LogoutAllExceptMe` ("log out user from all other sessions to ensure reauthentication after password change"). So the password change alone signs every other device out. Already-issued access JWTs stay valid until they expire (Supabase signout docs).
- So the sentence "Every device is signed out and the old password signs no one back in" is TRUE as built. The Sign Out Everywhere step before it is redundant.
- If the order ever mattered (a backend that stopped revoking on password change), "sign out first, then change" is the weaker order: an attacker holding the old password could sign back in between the two steps.
- Suggest to her: change the password first (which signs every other device out), then sign in again here. Or keep Sign Out Everywhere, but AFTER the change.
- Every other recipe sentence agrees with CastleRules; see the clean bill.

**F-11 [NIT] · `App/Variorum/VariorumTests/AlertCancelSweepTests.swift:248,251` · The guard's floors are brittle.** It requires at least 30 SwiftUI alerts and at least 4 NSAlerts, and the tree holds 33 and 4. Converting four alerts to sheets (VX-561's own fix, applied again) would turn the guard red for a non-bug. Consider "at least 20" plus the named-site check that is already there (`WingSwitcherMenu`'s field alert), which carries the non-vacuity on its own.

**F-12 [NIT — recorded residual, agreeing] · `MCPWriteTools+UnlinkVersions.swift:141` · The not-shared noun is "note" for an edge id.** An id naming nothing answers "That note isn't shared with this client, or doesn't exist." for an argument that named a link. The noun is fixed per tool, not per state, so a "link" noun would leak nothing. That makes it a pure copy choice for her pass. The batch's residual (2) already says this. Recorded so the round carries it.

## Clean bill (checked by this reviewer, found solid)

- **`unlink_versions` keeps VX-825's law.**
  - Both ends' READ decisions run before any rung or act-fact answer (`MCPWriteTools+UnlinkVersions.swift:92-98`). So a hidden far side, a Private side, a `derived_from` id, an end released to lineage and a missing id all answer the one shape.
  - The unreadable side's ask is raised silently: `MCPAsking.refusal` adds the asked sentence only for `rungTooLow` (`MCPGrantAuthority.swift:196-206`), so the text stays byte-identical.
  - Refused rows answer no target (`hidesTarget`).
  - Ran: `swift test --filter 'MCPUnlinkVersionsServerTests|MCPLinkVersionsServerTests|…'`, green. The VX-943 suite (10) and VX-187's suite passed. The record's discrimination run (3 reds with the read-first loop removed) matches the code's ordering.
- **The unlink act is sync-shaped and P1-shaped.**
  - One tombstone UPDATE on a synced table, captured by the outbox trigger; no `Sync/` line.
  - `mcpVersionLinkEnds` is a CROSS JOIN driven from the edge's key → the two blocks → `uq_cblock_ownership` → the container keys, so its cost is one edge.
  - `notesShareALiveVersionLink` is driven from one note's placements through `idx_edge_source` / `idx_edge_target`.
  - `revertVersionLinks`' lift into `tombstoneVersionEdges` is byte-equivalent (link's undo suite green).
- **The unlink's undo and redo follow VX-276.** The inverse revives only while the edge is dead on the act's own stamp with no live twin (`reapplyVersionLinks`). The redo re-tombstones only while the edge is live and re-stamps. The undo label "claude-code's version link removal" comes from the raw value.
- **The unlink's guard spends correctly.** `guardNotes` dedupes spends by grant id, so a link inside one note (`[n, n]`) spends one once grant, and two notes spend both or neither. `edge_id` is in VX-396's keys, `additionalProperties: false` gives VX-606, the null-characters count is 0, and `flushesHerEditorFirst = false` (no take's text is met). `link_versions`' new description matches its answer's actual keys (`MCPWriteTools+LinkVersions.swift:114,121`).
- **VX-934's AND is one rule in one place.**
  - `MCPAIMarksSwitch.drawn` is read by exactly `MCPSharedIcon`, `PrivateMarkView` and `WingSwitcherMenu.rowMark`.
  - The road's `==` gains the switch, and `answeringAsks`/`openingHere` copy it, so ⌘L's sheet follows.
  - Both windows hand `theme.settings.aiMarks`; RootView's body already read `theme.settings` (`theme.tokens(for:)`, `.onChange(of: theme.settings)`), so there is no new invalidation.
  - The eye's rule lost `badgesOn` at all eight hosts.
  - `ai_marks` is a token "1"/"0" read at READ with no seed, and no other setting-key registry needed it.
  - Ran: `OwnershipHideAndBadgesTests`, green.
- **VX-782's geometry.** Vertical pad kept (R17). Horizontal air is bleed via `.padding(.horizontal, -pad)` on the background, so the row keeps a plain row's measure and left edge. The emoji offset is `-pad + emojiOffset.width` from the same frame corner. `commentGutter`'s `rowLeading = commentRoom` keeps the face-to-frame relation unchanged. The 5-pt bleed fits inside the article's 24-pt side padding, so the ScrollView never clips it. There is one caller of `TakesCalloutFrame`. Red-on-old was watched at gate12.
- **VX-793's face host.** Without an `openRequest` (Takes), `openedByDoor` stays false and the seat is non-empty whenever the panel is open, so `faceAndPanel` reduces to the pre-VX-793 condition. In Compare, `commentsRequest` keyed by block id is unique per board: columns are distinct notes and I2 holds. The ask is cleared on teardown and when the ring migrates. F1's seat composes with a first comment arriving and leaving.
- **VX-848.** `readingMeasure` is `EditorTypography.maxColumnWidth` by reference, a constant. `lane`'s shape and the badge floor are unchanged.
- **VX-927.** `nowName(of:)` is byte-equivalent: a home take maps to `nowName(unplacedRelative: false)` = `theTakeNow`. The chip and the count read the one `speaksAsKept`.
- **VX-928.** `QuickEntryModel` is `@MainActor`, so `oneFilingInFlight`'s check-and-set completes before the first suspension. Two key-down Tasks in one turn meet the flag. VX-911's span is unchanged. `canFile` reads the one flag.
- **VX-841's core.**
  - `fileAsQuicknote` resolves the tag by path in the note's effective wing through the wing move's own `adoptPath` (no copy). `ensureQuicknotesBook` is Home-only and names Home's tag.
  - `importPost(wingId:)` refuses a dead wing (`requireLiveWing`), so the pick-to-mint race fails honestly.
  - The park's field is defaulted and macOS-only.
  - Ran: `QuicknoteWingTests` (6), green.
- **VX-843.** Both of her sentences are byte-verbatim (`TourScript.swift:327`; `SampleLibraryPrinceBook.swift:241`). The title-keyed trap answer agrees with the comments and code I read.
- **VX-916 against CastleRules, read in full:**
  - The E6 line is rule 3's clause plus VX-538's and R-529-5's constants, quoted, not re-typed.
  - R2 matches rules 6/7: "Record your twelve words…" mints new ones (`wordsSectionLine`).
  - R3 matches rule 11 (a new library key and a new sync key), rule 12 (leaving gives a new Standard key) and rule 15 (the sync key changes only on entry). The record's forced departure from her "changes no key" is correct.
  - R4 matches rules 11/12's roads. R5 promises nothing about the past (rules 4/5/15).
  - Nothing claims the Apple account or an unlocked device is covered (rules 8/10).
  - No `Protection/` file is edited.
- **VX-852.** Both hooks sit where the record says: after the clean-tree refusal, and after `AE` but before the first notarize and before `ls_sweep`'s `rm -rf "${BUILD_DIR}/DerivedData"`. The archive's DerivedData is `${OUT}/build.noindex/DerivedData` (`archive-and-export.sh:160`, matching `BUILD_DIR`). `verify-pins.txt` lives beside DerivedData, not in it. Ran: `ReleasePinsWiringTests`, green.
- **VX-888 hollow.** The repro suite ran green here too (`SearchPunctuationOnlyTests`, 6 + 3 cases). No product line changed.
- **No word-level tracking, no cross-entity text copy, no corpus-scaled read** anywhere in the diff.
- **Ran:** one targeted headless run, `swift test --filter 'QuicknoteWingTests|SearchPunctuationOnlyTests|ReleasePinsWiringTests|OwnershipHideAndBadgesTests|MCPUnlinkVersionsServerTests|MCPLinkVersionsServerTests'`: "14 tests in 2 suites passed" and "19 tests in 4 suites passed", EXIT 0. No whole-target runs, no `xcodebuild`, per the machine rule.
