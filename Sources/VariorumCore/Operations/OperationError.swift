import Foundation

/// Typed refusals from the operations layer. Every guard an invariant or spec
/// rule requires surfaces as one of these — never a silent no-op, never a
/// SQLite error leaking domain meaning.
public enum OperationError: Error, Equatable, Sendable {
    // Missing or tombstoned targets.
    case containerNotFound(id: String)
    case containerNotDeleted(id: String)
    case blockNotFound(id: String)
    case variantNotFound(id: String)
    case commitNotFound(id: String)
    case readingNotFound(id: String)
    /// `restoreReading` addressed a reading that is not deleted (13b 4F —
    /// N37/S4-28.2; the containerNotDeleted/sectionNotDeleted parallel).
    case readingNotDeleted(id: String)
    case tagNotFound(id: String)
    case referenceNotFound(id: String)

    // Wrong target shape.
    case wrongContainerKind(id: String, expected: ContainerKind)
    case wrongReadingKind(id: String, expected: ReadingKind)
    /// The journal's day key must be canonical "yyyy-MM-dd" (Phase 8; the
    /// notebook rule keys on it, as the retired Phase 9b bridge join did — a
    /// malformed key would mint a day-page the canonical key can never
    /// find again).
    case invalidEntryDate(String)

    // Locks (reversible guards, I6).
    case lockedPost(id: String)
    case lockedVariant(id: String)
    case lockedReading(id: String)
    /// 13i-a: the daily Journal's journal trait is CONSTITUTIVE — its
    /// profile IS the 'daily' marker (the identity memo §3), so the
    /// per-book trait toggle refuses on it rather than silently demoting
    /// the marker (PROVISIONAL, the 13i-a plan §9).
    case dailyJournalTraitIsConstitutive(id: String)

    // Variant lifecycle.
    /// I10: removing a live block's last live active variant is deleting the
    /// block — the caller should call `deleteBlock` instead.
    case lastActiveVariant(id: String)
    /// The ops-layer live guard the schema's RESTRICT cannot provide under
    /// soft delete: a variant some live slot renders cannot be removed.
    case variantIsChosen(id: String)
    case archivedVariant(id: String)
    /// `restoreVariant` addressed a take that is not deleted (13j, sitting
    /// round 5 — the deleted-take recovery door). The
    /// `containerNotDeleted`/`readingNotDeleted`/`sectionNotDeleted`/
    /// `commentNotDeleted` parallel, one row-kind further down: a recovery
    /// door that silently succeeded on a LIVE take would teach that Put back
    /// did something when it did nothing.
    case variantNotDeleted(id: String)

    /// A `deleteBlock` carrying `BlockDeletionPrecondition
    /// .emptyWithNothingUnshown` found the block holding prose its slot does
    /// not render — a second live take (a fan, or an archived one) or a live
    /// block comment (13c Stage 1 ladder, R3-1). The A7 seam-backspace carve
    /// is authorized ONLY on "there is no text to lose"; when that stops
    /// being true between the keystroke and the transaction, the whole
    /// gesture refuses rather than deleting text nobody saw.
    case blockCarriesUnshownText(id: String)

    // Placement (I2).
    case blockAlreadyPlaced(id: String)
    case blockNotPlaced(id: String)
    case blockNotDeleted(id: String)

    // Block archive (13j, her round-7 ruling — the third verb beside delete
    // and move-to-scraps). Both are the `variantNotDeleted` class: a door
    // that silently succeeded on a block already in the state it asks for
    // would teach that it did something.
    case blockAlreadyArchived(id: String)
    case blockNotArchived(id: String)

    // Reading membership.
    case postNotInReading(postID: String, readingID: String)
    case alreadyInReading(postID: String, readingID: String)
    case readingAtCapacity(id: String)
    /// 13i-b U1 — a judgment op (`seatArrival` / `dismissArrival`) named a
    /// row that is not a live ARRIVAL: missing, already judged (seated or
    /// dismissed), or a member all along. A door that silently succeeded on
    /// a decided pair would teach that it did something.
    case arrivalNotFound(id: String)
    /// 13i-b U1 — `tagAllMembers` was asked for the book's own auto-tag and
    /// the book has none set (the "also tag the N current members" offer
    /// exists only beside an auto-tag; the bulk door names its tag).
    case readingHasNoAutoTag(id: String)
    /// 13i-c (R-13ic-4, her post-close ruling: "I just don't think that a
    /// rule-less gathering makes sense"): a GATHERING is minted with a rule
    /// and keeps one — the mint and the rule write both refuse NULL. (A book
    /// may carry no rule: "collects nothing by itself".)
    case gatheringRequiresRule(id: String)

    // Ownership (13i-c U2 — the sitting record §1, §2, §6, §18.4; the 13i-c
    // plan §3). The ONE choke point every membership road routes through
    // (`addPostToReading`, the arrival seat) consults `OwnershipDecision`;
    // where a plain pointer would break an ownership promise it refuses with
    // the choice the door must OFFER instead (P-2 — never a bare refusal
    // where a ceremony exists). Each carries the ids the door needs to name
    // the books.
    /// An OWNED book met a note that lives in other books: the door offers
    /// COPY IN (the original keeps its lives) or MOVE IN (`elsewhere`'s
    /// memberships severed, listed) — §6. `elsewhere` lists the other live
    /// books holding the note as a member, earliest membership first.
    case noteMemberedElsewhere(postID: String, readingID: String, elsewhere: [String])
    /// A PLAIN book met a note an owned book (`owner`) holds: only a COPY can
    /// come in — §4/§6's "copy in / dismiss".
    case noteOwnedElsewhere(postID: String, readingID: String, owner: String)
    /// The book is SEALED (§5 — Finished + text immutability): `unlockReading`
    /// (Reopen) refuses there, because the ONE door down from Sealed is
    /// Unseal, which reopens the book too (R-13ic-3).
    case readingSealed(id: String)
    /// 13i-c (the architect's ruling on U2's F-U2-1): a note's own Unseal
    /// refuses while a LIVE SEALED book holds it as a live member — "Sealed =
    /// the book is done" binds every member's text; the book's Unseal is the
    /// road (and it reopens the book, R-13ic-3).
    case noteInSealedBook(postID: String, readingID: String)
    /// `unsealReading` addressed a book that is not sealed (the
    /// `readingNotDeleted` class — a door that silently succeeded would teach
    /// that it did something).
    case readingNotSealed(id: String)
    /// A SHALLOW duplicate of an OWNED book would point a second book at its
    /// notes — the one thing owning forbids; an owned book duplicates only
    /// "with copies" (§6).
    case ownedBookDuplicatesDeep(id: String)

    // Book archive (13i-e U1 — R-13ie-1…4; the 13i-e plan's U1 RECORD).
    // Both are the `blockAlreadyArchived`/`readingNotSealed` class: a door
    // that silently succeeded on a book already in the state it asks for
    // would teach that it did something — and re-stamping an archived book
    // would orphan the exact-stamp key its archived-with-notes members carry.
    case readingAlreadyArchived(id: String)
    case readingNotArchived(id: String)
    /// THE DAILY JOURNAL CAN BE ARCHIVED, NEVER DELETED (13i-e — the sitting
    /// record §10's ruling on the ⌘J ground: "the daily Journal can be
    /// archived, never deleted; it returns when a day arrives"). Both delete
    /// doors (`deleteReading`, `deleteReadingWithNotes`) refuse a book
    /// wearing the 'daily' marker, checked inside their write transaction;
    /// the road is `archiveReading`.
    case dailyJournalCannotBeDeleted(id: String)

    // Structural operations (Phase 3).
    /// Extract's span is not a boundary-adjacent prefix/suffix of the
    /// rendered variant's text (a middle span is a divide), or it is blank,
    /// out of bounds, grapheme-splitting, or the whole text.
    case spanNotExtractable(blockID: String)
    /// A cut offset that is out of bounds, splits a grapheme cluster, or
    /// leaves an empty half after seam trimming.
    case invalidCut(variantID: String, cut: Int)
    /// Single-variant divide addressed a block with more than one live
    /// active variant — that is the multi-variant W ceremony (`divideW`).
    case fannedBlock(id: String)
    /// divideW needs at least one marked variant to carry the cut through.
    case noMarkedVariants(blockID: String)
    /// divideW parking (13b Stage 4, S4-22 ruling 2): a cut at a take's
    /// very end parks the whole take on the FIRST successor; at its very
    /// start, on the SECOND. If every marked take parks at the same end,
    /// the other successor would be born with no takes — an I10 violation
    /// by construction — so the operation refuses (the ceremony sheet
    /// gates the same state with honest copy; this is the belt behind it).
    case divideSideWouldBeEmpty(blockID: String)
    /// Merge requires its two blocks placed adjacently in one container.
    case blocksNotAdjacent(first: String, second: String)
    /// The merge ceremony (13b Stage 4, S4-23): the merged block must be
    /// born with at least one take — ≥1 pairing or ≥1 carry (I10 at
    /// confirm; the sheet gates the same state with honest copy, this is
    /// the belt behind it).
    case mergedBlockWouldHaveNoTake(first: String, second: String)
    /// The merge ceremony's pairing arity, v1 (PROVISIONAL — 1:1 by
    /// construction): each take participates in at most ONE pairing, and a
    /// paired take cannot also be carried. "Pairing is choosing by hand."
    case takePairedTwice(variantID: String)
    /// poolDragCopy's source must live in a pool.
    case blockNotInPool(id: String)
    /// 13e batch 3 (E5 — her A20): a BLANK take has no prose to become a
    /// block, so `takeToBlockBelow` refuses rather than minting an empty
    /// block (the `divideSideWouldBeEmpty` family — architect ruling AR-1(d);
    /// `takesToBlocks` SKIPS blank takes instead, and says so).
    case emptyTakeCannotBecomeABlock(variantID: String)
    /// 13e batch 3 (E6b — her A21): `takesToBlocks` found nothing to convert
    /// — the block's fan holds no other take with prose beside the one it
    /// shows (an unfanned block, or a fan of blanks).
    case noConvertibleTakes(blockID: String)
    /// A live block whose slot resolves to no live variant — unreachable
    /// through the operations layer (I10 + default reassignment); a distinct
    /// case so a sync-race arrival diagnoses cleanly (Phase 5).
    case noRenderableVariant(blockID: String)

    // Tags.
    case duplicateTagPath(path: String)
    case invalidTagName(name: String)
    case alreadyTagged(tagID: String, targetID: String)
    case tagNotApplied(tagID: String, targetID: String)

    // Owner identity (Phase 9c).
    /// `adoptOwnerID` was called while signed out — an adoption pass has
    /// nothing to stamp without an identity.
    case noOwnerIdentity

    // version_of + the copy operations (Phase 11, Step A2).
    /// A version link needs two distinct blocks.
    case cannotVersionLinkBlockToItself(id: String)
    /// The live version_of pair already exists (either orientation — the
    /// canonical (min,max) storage makes them one relationship).
    case versionLinkExists(a: String, b: String)
    /// `removeVersionOf` found no live link between the pair (round 1
    /// NIT: the un-mark's refusal must say the truth, not its opposite).
    case versionLinkNotFound(a: String, b: String)
    /// The post-level door needs an anchor block; a blockless post has none.
    case postHasNoBlocks(id: String)
    /// The two posts are already version-linked (some live version_of edge
    /// joins their placed blocks).
    case postsAlreadyVersionLinked(a: String, b: String)

    // The VERSIONS family (the post-13l polish round, ledger rows 16/23).
    /// A restore or a promote named a container that is not this note's
    /// saved version — the classifier's own answer, refused rather than
    /// guessed at. **Version history is a BIRTH FACT and a live link**
    /// (`archived_at = created_at` from one clock call, plus a live
    /// `version_of` edge to the note): a note that was ever LIVE is a work,
    /// never version history, and neither door may treat one as the other.
    case notVersionHistory(version: String, note: String)

    // Deferred editor compounds (Phase 11, A9 — the #11 rulings).
    /// A compound planned against one surface found a newer buffer at
    /// execution (the edit-during-await class): the whole batch refuses —
    /// visibly, never a clobber. Retry the gesture on the current text.
    case bufferChangedSinceGesture(variantID: String)

    // Lenses (Phase 11, Step A1 — v1_7).
    case lensNotFound(id: String)
    case invalidLensName(name: String)
    /// `clearLensChoice` found no live override for the (lens, block) pair.
    case lensChoiceNotFound(lensID: String, blockID: String)

    // Canvas layout (Phase 11, Step A1).
    /// A canvas position addresses a block whose live placement is not the
    /// named container — the canvas shows exactly the container's own
    /// blocks (I2 gives at most one placement to check).
    case blockNotInContainer(blockID: String, containerID: String)
    /// `removeCanvasPosition` found no live layout row for the pair.
    case canvasPositionNotFound(blockID: String, containerID: String)

    // Import (Phase 11b, Step B2).
    /// The dropped text held nothing to import (whitespace-only —
    /// `bulkSegments` mints no block from it, so the gesture refuses
    /// instead of minting an empty post).
    case emptyImport

    // Block presentation (Phase 13, Step A1 — v1_9).
    /// A presentation frame must name a non-empty kind.
    case invalidPresentationKind

    // Block comments (Phase 13, Step A1 — v1_8).
    case commentNotFound(id: String)
    /// A comment must say something — whitespace-only text refuses (an
    /// empty note is a delete, not an edit).
    case invalidCommentText
    /// `restoreBlockComment` addressed a comment that is not deleted.
    case commentNotDeleted(id: String)

    // Reading extents (Phase 13, Step A1 — v1_11 + the max_posts face).
    /// An extent (word target or post cap) must be positive; nil clears.
    case invalidExtent(value: Int)

    // The custom colour palette (18g — her R-Q6/R-Q13).
    /// A palette seed must be six hexadecimal digits (`ThemeTint` is the
    /// one rule). The payload is what she TYPED, so the refusal can show
    /// it back to her. nil clears; this is only ever a malformed value.
    case invalidTint(value: String)

    // Reading sections / chapters (Phase 13, Step A1 — v1_10).
    case sectionNotFound(id: String)
    case invalidSectionName(name: String)
    /// A membership can only be assigned to a section of ITS OWN reading.
    case sectionNotInReading(sectionID: String, readingID: String)
    /// `restoreSection` addressed a chapter that is not deleted.
    case sectionNotDeleted(id: String)

    // The Bookcase's SHELVES (13i-d U1 — the sitting record §7/§19/§20/§24;
    // `Operations+Shelf.swift`).
    /// No live shelf with this id — or none in the book's own wing (a shelf
    /// never holds a book of another wing; wings are separate libraries, §9).
    case shelfNotFound(id: String)
    /// A shelf needs a name (duplicates are legal — no natural key).
    case invalidShelfName(name: String)
    /// A glyph is ONE grapheme and never an emoji (§7). The payload is what
    /// she typed, so the refusal can show it back.
    case invalidShelfGlyph(value: String)
    /// A shelf minted into a wing that is not live ('' — Home — always is).
    /// 13i-d U5: also every wing op addressed at Home (virtual — never
    /// renamed or deleted) or at a dead/unknown wing, and a move/copy whose
    /// destination is not live.
    case wingNotFound(id: String)

    // WINGS (13i-d U5 — the sitting record §9; R-13id-2; `Operations+Wing.swift`).
    /// A wing needs a name.
    case invalidWingName(name: String)
    /// A DOOR that names a wing found a live wing (or Home) already wearing
    /// that name (`assertWingNameIsFree` — E13's door-guard shape; the op
    /// itself allows duplicates, the schema's no-natural-key letter). The
    /// payload is the EXISTING name in its own casing.
    case duplicateWingName(name: String)
    /// R-13id-2 — Delete Wing refuses while the wing holds any live note, book,
    /// gathering or tag; the payload carries the counts so every face NAMES
    /// what remains.
    case wingNotEmpty(id: String, contents: Queries.WingContents)
    /// A move/copy to the wing the note already lives in.
    case postAlreadyInWing(postID: String, wingID: String)
    /// A book never spans wings (§9): a membership refuses a note of another
    /// wing — the book choosers list only the note's own wing's books, so no
    /// face reaches it; this is the invariant's op-level belt.
    case crossWingMembership(postID: String, readingID: String)
    /// 13n-c U6 — an MCP wing move's undo or redo found the note has JOINED a
    /// book or TAKEN a tag in the wing it would now leave since the move (or
    /// since the undo): replaying the move's exact rows would split a book or
    /// a vocabulary across wings (§9), so the replay refuses and KEEPS its
    /// entry — she takes those off (or moves the note with her own door), then
    /// tries again (PROVISIONAL P-13nc-U6-3).
    case wingMoveChangedSince(postID: String)
    /// #169(b), RULED — THE DAILY JOURNAL IS HOME-ONLY: a book of another wing
    /// cannot be designated, and the daily Journal never leaves Home.
    case dailyJournalIsHomeOnly(id: String)
    /// 13i-d U5b — a book or gathering moved to the wing it already lives in
    /// (`moveReadingToWing`; the door lists only the OTHER wings).
    case readingAlreadyInWing(readingID: String, wingID: String)
    /// 13i-d U5b — "Move everything to another wing" aimed at the wing itself
    /// (`moveWingContents`; the door lists only the OTHER wings).
    case wingMoveIntoItself(wingID: String)
    /// A hand placement ("my order") named an anchor that is not on the
    /// moving book's shelf — the drag's target moved under it.
    case placementAnchorNotOnShelf(readingID: String, anchorID: String)

    // Stars (13f W4 — her round-3 ruling: "up to 5 notes or books").
    /// The star list is full. Refused rather than silently evicting the
    /// oldest star: a cap she cannot see acting on its own would be the
    /// one outcome she never asked for, and the refusal names un-starring
    /// as the road (P-2 — the door fires and speaks).
    case starLimitReached(limit: Int)

    // Book names (Phase 13e, E13 — her kickoff-sitting round-3 ruling).
    /// A DOOR that names a book found a LIVE book already wearing that name
    /// (case-insensitively — `BookNaming`). The payload is the EXISTING
    /// book's stored name, not what she typed, so the refusal can show her
    /// the book she already has in its own casing.
    ///
    /// Deliberately NOT thrown by `createReading`/`renameReading`: this is a
    /// door guard (`assertBookNameIsFree`), never an operation-level
    /// invariant — the offline race stays legal, and the seeders, the daily
    /// book's own ensure and the sync apply path must never refuse for a
    /// name reason.
    case duplicateBookName(name: String)

    // The purge intent (Phase 13j batch 6b — the memo's §4a; her round-3
    // ruling seats the doors in the Trash only).
    /// `requestPurge` addressed a row that is not deleted: only things in
    /// the Trash can be purged — a live row's road is delete first (and a
    /// full-delete door must never exist in a note context, her rider).
    case purgeTargetNotDeleted(table: String, id: String)
    /// `requestPurge` was handed a table the purge design does not name
    /// (the memo's roots: container / reading / block / variant, plus
    /// commit_point for pruning). A programmer-error class, refused loudly.
    case unsupportedPurgeTarget(table: String)
    /// **Deliberate ⌘S commits are NEVER pruned, in either mode** (her
    /// round-9 ruling) — the op-level belt behind `SavepointPruning`'s
    /// quiet-only brain: an intent naming a manual savepoint refuses.
    case deliberateSavepointNeverPruned(id: String)

    // Smart collection (taste checkpoint, Sitting 9 — R98).
    /// The smart reading's filter cannot be satisfied by tagging (date
    /// bounds, a profile mismatch, an archived post, a malformed spec, or
    /// a filter tag that no longer exists) — refused with a DESCRIPTIVE
    /// reason naming the filter, per the author's ruling ("it should give
    /// you a descriptive error message when you can't add something").
    case smartFilterUnsatisfiable(readingID: String, reason: String)

    // THE MCP DOOR's grants store (13n-b U1 — `Operations+MCPGrants.swift`;
    // these speak in Settings ▸ MCP, the technical register — P-13n-1).
    /// A client named itself with nothing (blank `clientInfo.name`).
    case mcpInvalidClientName(name: String)
    case mcpClientNotFound(id: String)
    case mcpGrantNotFound(id: String)
    /// A grant to a client that is pending or denied — approve it first.
    case mcpClientNotApproved(id: String)
    /// The grant's target is not a live note / book / wing of its kind.
    case mcpGrantScopeNotFound(kind: String, id: String)
    /// A journal's or a Private book is never a grant's scope (its notes are
    /// shared one ask at a time), and a fenced note never takes "always"
    /// (R-13n-4; R-13nb-1/4).
    case mcpGrantScopeFenced(kind: String, id: String)
}
