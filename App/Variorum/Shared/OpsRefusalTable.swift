//
//  OpsRefusalTable.swift
//  Variorum (shared: Mac + Mobile)
//
//  **THE OPERATIONS LAYER'S REFUSALS, IN THE APP'S WORDS — ONE TABLE, BOTH
//  PLATFORMS** (18m U3 — the post-13u health review's leak 2).
//
//  `OpsRefusalCopy` was born Mac-app-local (Phase 13b Stage 1b, AD-14: it
//  used to be `TakesViewModel.message(for:)`, and three features reached
//  into Takes for it). The phone never had it, so every phone door kept its
//  own `OperationError` switch, each covering a different subset and each
//  falling back to a raw enum dump — and the Mac's Write editor kept a
//  PRIVATE second switch (`operationMessage`) beside this one, the two
//  already disagreeing on the sealed-note sentence (the review found it
//  spelled three ways; the 18m trace found the whole family).
//
//  **WHAT IS SHARED AND WHAT IS NOT (MobileSoul §4 item 4, read from the
//  other side — a shared home must not hold words naming a platform's own
//  doors).** This file holds every sentence that names no platform door or
//  chord. A sentence that is shared EXCEPT for one door arrives here as a
//  ROAD — a slot in `OpsRefusalRoads` each platform fills (the hoisted
//  `CrossBlockRefusal`'s `fanRoads:` is the worked precedent). A sentence
//  that is one platform's own (a Mac chord, a Mac-only surface's controls,
//  the Mac's pick vocabulary) stays in that platform's half: the Mac's is
//  `Variorum/Registry/OpsRefusalCopy.swift`, which also keeps the
//  pre-hoist `message(for:)` so every Mac call site and pin reads exactly as
//  before (the 3C parity pattern). `OpsRefusalTableIntegrityTests` walks
//  THIS file's string literals and fails on either platform's door or chord
//  vocabulary.
//
//  **`words(for:roads:)` answers nil where the table has no words**, so a
//  caller that already has a better fallback than "Refused: …" keeps it —
//  the collapse of a platform's own switch onto this table can only turn
//  dumps into sentences, never a sentence into a dump.
//

import Foundation
import VariorumCore

/// **THE ONE SEALED-NOTE SENTENCE** (18m U3 — her copy, PROVISIONAL:
/// QUESTIONS #159). *"This note is sealed — unseal it first."* — and a door
/// that knows what the seal refused names it: *"…unseal it to edit."*
///
/// Before this the one refusal read FOUR ways across the two apps' gates and
/// tables (and a dozen more beside them, enumerated in the 18m U3 record):
/// "unlock it to edit", "unlock it first", "unseal it to change takes or
/// choices" — whose act clause was false at most of the doors that spoke it —
/// and the phone's "locked — unlock it to edit". The SHAPE is shared; the
/// NOUN and the VERB are each platform's own, because they name its door (the
/// Mac's Seal / Unseal; the phone's Lock Note / Unlock Note — MobileSoul §4
/// item 4), so they arrive as `Words` from the platform's own target.
nonisolated enum SealedNoteCopy {
    /// A platform's door words for the note seal: the state the door puts a
    /// note in, and the verb of the door that lifts it.
    struct Words: Sendable, Equatable {
        let state: String
        let verb: String
    }

    static func sentence(act: String? = nil, words: Words) -> String {
        "This note is \(words.state) — \(words.verb) it "
            + (act.map { "to \($0)." } ?? "first.")
    }
}

/// The ONE-DOOR-WORD slots a platform fills. Each is a sentence's only
/// platform-shaped fragment; `nil` means the platform has no such door and
/// the sentence must not promise one (the `deletedRegionExplainer(purgeRoad:)`
/// precedent).
nonisolated struct OpsRefusalRoads: Sendable {
    /// The note seal's door words (`SealedNoteCopy`).
    let seal: SealedNoteCopy.Words
    /// The DIVIDE chord, spoken in parentheses after the divide road.
    let divideChord: String?
    /// How a fanned divide can be arranged differently — the Mac's ceremony
    /// door. The phone never replicates ceremonies (her ruled exclusion), so
    /// it passes `nil` and the sentence ends at the keep-on-top fact, which is
    /// true on both platforms (U-2).
    let arrangeTakesRoad: String?
    /// 13i-c U2 — the BOOK seal's words: its state noun (the sitting record
    /// §5's ruled "Sealed Book") and the verb of the door that lifts it, or
    /// nil where the platform has no such door yet (the phone's book-seal face
    /// is the mobile catch-up's — the sentence then must not promise one). A
    /// road, because the seal's stem is a platform's door word to this file's
    /// integrity walk (the NOTE seal reads "locked" on the phone).
    let bookSeal: BookSealWords

    struct BookSealWords: Sendable, Equatable {
        let state: String
        let verb: String?
    }
}

nonisolated enum OpsRefusalCopy {
    /// The table's words for `error`, or nil where it has none (the caller's
    /// own fallback speaks then).
    static func words(for error: Error, roads: OpsRefusalRoads) -> String? {
        guard let error = error as? OperationError else { return nil }
        switch error {
        // 18m U3 — the ONE seal sentence (the ruling's (a)): the act-less
        // form, because this table cannot know which door refused.
        case .lockedPost:
            return SealedNoteCopy.sentence(words: roads.seal)
        case .archivedVariant:
            return "That take is archived — unarchive it first."
        // 13j batch 3 (the round-5 deleted-take ruling): the recovery
        // door's double-click / raced-restore path — the
        // `readingNotDeleted` sentence, one row-kind down. It is a
        // SUCCESS story told as a refusal, so it says so.
        case .variantNotDeleted:
            return "That take is already back — it's in the block's fan."
        // 13n-b U4 — its BLOCK twin (the same J8 class, red-on-old in
        // `MCPNavigationTests`): a raced `put_back` on the wire, and any door
        // routed through this table, spoke the raw enum. The recovery doors'
        // own sentence (`DeletionRefusal`'s "already back" family).
        case .blockNotDeleted:
            return "That block is already back."
        // 13j batch 6b (J1): the purge op's refusals, worded — never the raw
        // dump (the J8 bar, in the phase whose bar is copy truth). The first
        // is the honest impossible-door case: only things in the Trash can be
        // deleted for good. (The deliberate-savepoint sibling names ⌘S, so it
        // is the Mac half's.)
        case .purgeTargetNotDeleted:
            return "Only things in the Trash can be deleted for good — "
                + "delete it first, and it waits there \(TrashWindow.days) days."
        case .unsupportedPurgeTarget:
            return "That isn't something the Trash can delete for good."
        case .lockedVariant:
            return "That take is locked — unlock it or branch a new take."
        // 13u3 UNIT H (the enum-dump straggler this unit's own door
        // walked straight into). `deleteVariant` checks the CHOSEN
        // pointer before the last-active guard, so the commonest press
        // on a take card's Delete — the take the note is showing, and on
        // a one-take block the ONLY take — raises this; it fell to
        // `default:` and printed `Refused: variantIsChosen(id: "…")`,
        // a raw enum with a UUID in it, on a door Write's panel has
        // offered since Phase 7. The words answer BOTH readers, because
        // one error serves both states: "choose another first" is the
        // road on a fan, and on a block with nothing else to show the
        // thing she means to delete is the block.
        case .variantIsChosen:
            return "The note shows this take \u{2014} choose another take first, and then "
                + "this one can go. (If it's the block's only take, it's the block "
                + "you want to delete.)"
        // 13u3 ladder round 1, R1-4 — the enum-dump class's two
        // stragglers, first reachable from a face at UNIT D's rename
        // door (race-only: the take dying or the moment purged under the
        // open ask). Worded generically, because `variantNotFound` is
        // every op's honest answer to a take that is gone.
        case .variantNotFound:
            return "That take isn't there any more \u{2014} it may have just been "
                + "deleted. The block's History lists deleted takes, with Put back."
        case .commitNotFound:
            return "That saved moment isn't there any more."
        case .versionLinkNotFound:
            return "These two notes aren't marked as versions — nothing to unmark."
        // 17o batch d (ledger row 27, J8): the mark door's own refusal
        // fell to `default:` and printed the raw enum WITH BOTH POST
        // UUIDs in it — on a click she can make by pressing the row
        // twice. Its inverse above has spoken since Sitting 9; this is
        // the missing half of that pair.
        case .postsAlreadyVersionLinked:
            return "These two notes are already marked as versions of each other."
        // Same batch, same class. Since row 17 the VERSION-LINK door no
        // longer raises this at all (a blockless note gains its anchor
        // block — her U-19 (1)); what survives are the COPY roads —
        // Compare's "make outline note" and duplicate-as-version — where
        // there is genuinely nothing to copy. `VersionActs.words` has its
        // own sentence for the note-moments family, whose "save a version
        // of" phrasing belongs only there.
        case .postHasNoBlocks:
            return "There's nothing in that note yet — write a line in it first."
        // 13b Stage 4 ladder round 1, MINOR-2: the two Stage 4 doors
        // that spoke raw enum dumps get app words. `readingNotDeleted`
        // is the recovery door's double-click/raced-restore path;
        // `readingNotFound` is its absent-row sibling AND the shared
        // `liveReading` guard's refusal (missing OR tombstoned) from
        // every reading op, so the copy serves both meanings.
        case .readingNotDeleted:
            // 13i-d U6 (a): platform-NEUTRAL (the phone's area is still
            // "Shelf" until its catch-up; the Mac's is the Bookcase).
            return "That book is already restored — it's back where it was."
        case .readingNotFound:
            return "That book can't be found — it may have been deleted, "
                + "or removed on another device."
        // The belt behind the extent faces (same finding): the ops
        // layer refuses non-positive targets/caps typed nowhere the
        // ONE `ExtentInput.parse` rule now guards.
        case .invalidExtent:
            return "A word target or note cap must be a positive number — "
                + "nothing was changed."
        // 18g (her R-Q13's custom hex): the belt behind the palette
        // field. The refusal shows back what she typed and says the
        // shape, because "invalid" without an example is the R1-3
        // class — and it names that nothing moved, since a half-written
        // pair is exactly what the one-transaction setter prevents.
        case .invalidTint(let value):
            return "\u{201C}\(value)\u{201D} isn't a colour — a colour is six hex "
                + "digits, like B9A7E6 or #8A7A3A. Nothing was changed."
        // 13d Batch 3 (A9): reachable the moment divide has a door
        // on a board — the fan is read from the store and the op
        // re-checks it inside its own transaction, so a take arriving
        // in that window refuses HERE. It dumped the raw enum before.
        // The ARRANGE road is the Mac's ceremony chord, so it is a slot.
        case .fannedBlock:
            return "This block has more than one take now — divide it again "
                + "and the take you're in splits while the others stay on the "
                + "first block" + (roads.arrangeTakesRoad.map { " (\($0))" } ?? "") + "."
        // 13e E13: her round-3 ruling's words, from the one home above.
        case .duplicateBookName(let existing):
            return BookNameCopy.refusal(existing: existing)
        // 13c Stage 1 ladder, R3-1: the empty-block carve's
        // authorization, re-checked inside the tombstone's own
        // transaction — worded for any door onto
        // `deleteBlock(requiring:)` so none inherits the raw dump (the
        // R1-3 class).
        case .blockCarriesUnshownText:
            return "That block isn't empty after all — it carries a take or "
                + "a comment that isn't shown here. Nothing was deleted."
        // 13e batch 3 (E5/E6b — her A20/A21): the take↔block doors'
        // three refusals, in words. `lastActiveVariant` has existed
        // since Phase 2 and dumped the raw enum; E5 makes it a door she
        // will actually meet (a one-take block has nothing to move out).
        // **18m U3, FORK L-c (PROVISIONAL, QUESTIONS #159):** ONE guard
        // (`ensureNotLastActive`) raises this behind THREE acts — archive
        // (⌘⇧A), delete, and E5's move-out — and the two sentences the Mac
        // used to speak were each wrong at the other's door: E5's "a take
        // moves out … Divide the block instead" answered an archive, and
        // Write's "delete the block instead" answered a move-out. So it names
        // BOTH real roads, keeping each old sentence's fact. The divide
        // chord is a slot.
        case .lastActiveVariant:
            return "This block has only one take — a block keeps at least one take, "
                + "so delete the block instead, or divide it"
                + (roads.divideChord.map { " (\($0))" } ?? "") + " to split it into blocks."
        case .emptyTakeCannotBecomeABlock:
            return "That take is empty — there's no text to become a block."
        case .noConvertibleTakes:
            return "This block has no other takes with text in them — "
                + "nothing to turn into blocks."
        // Ladder round 2 (R2-2): `blockNotFound`'s mid-flight sibling —
        // the block is live but its placement left this note between a
        // door's read and its write. First made reachable by the
        // multi-pick doors; spoke the raw enum until now.
        case .blockNotPlaced:
            return "That block is no longer in this note — it may have "
                + "moved while you worked. Nothing was changed here."
        // **13u1 UNIT 2 (item 8's U-3, the Mac half of the gap fence's
        // missing face).** A span covering an interior block that has NOT
        // ARRIVED renders that block with zero length; the compound's run
        // fences the gap before any op runs, so this is the belt behind
        // that brace: the ordinary race, a block landing or leaving between
        // a plan and its write. The phone has said this sentence since M22
        // (in its own "paragraphs", with its own `nothingWas` slot — its
        // structural door keeps that arm), and the two are the same reading.
        case .blocksNotAdjacent:
            return "Something sits between these blocks — a block that hasn't "
                + "arrived yet, or one that landed since you selected. "
                + "Nothing was changed."
        // 13j batch 6 (the enum-dump straggler routed from LADDER A's
        // round-1 sanity pass). Every structural op resolves its text
        // through `renderedVariant`, which throws this when a slot renders
        // NOTHING — a GAP SLOT is the shipped case. It is unreachable for a
        // healthy live block (I10 plus the default-variant reassignment
        // guarantee one), which is exactly why the words describe the state
        // it really means — text that has not arrived here yet — rather
        // than blaming her for a block she can see.
        case .noRenderableVariant:
            return "That block has no text here yet — it may still be "
                + "arriving from another device. Nothing was changed; "
                + "try again in a moment."
        // **18m U3 — the words only ONE switch had** (every other door
        // dumped "Refused: …"). The compare-and-set refusal was Write's
        // private switch's alone: a gesture whose buffer moved while it was
        // landing refuses, and the sentence carries the rollback. (The
        // phone's structural door keeps its own arm — its `nothingWas`
        // names "deleted" at its delete doors.)
        case .bufferChangedSinceGesture:
            return "The text changed while that gesture was landing — nothing was "
                + "altered; try it again on the current text."
        // Byte-identical on both platforms already, in two homes each: the
        // phone's structural door and the Mac planner's `.nothingToDo` said
        // this one; both comment faces said the next.
        case .invalidCut:
            return "No legal cut spot for that here — cuts land between words, "
                + "at sentence ends, and at line breaks."
        case .invalidCommentText:
            return "A comment needs some text."
        // 13i-c (R-13ic-4): a gathering is minted with a rule and keeps one.
        case .gatheringRequiresRule:
            return "A gathering needs a rule — add one to make it, or delete the gathering."
        // 13i-c U2 — the OWNERSHIP consult's two refusals (the sitting record
        // §6; the 13i-c plan §3). Each names the CEREMONY the door offers in
        // its place — copy in / move in — never a door (a face that can host
        // the choice offers it; the phone's sheets are the mobile catch-up's).
        case .noteMemberedElsewhere:
            return "That note already lives in another book, and this book owns its notes — "
                + "it can come in as a copy, or move in and leave its other books."
        case .noteOwnedElsewhere:
            return "That note belongs to a book that owns its notes — "
                + "it can come in here only as a copy."
        // The book seal (R-13ic-3): the one door down from it reopens the book.
        case .readingSealed:
            if let verb = roads.bookSeal.verb {
                return "This book is \(roads.bookSeal.state) — \(verb) it to reopen it."
            }
            return "This book is \(roads.bookSeal.state), so it can't be reopened here."
        case .readingNotSealed:
            return "That book isn't \(roads.bookSeal.state) any more — nothing changed."
        // 13i-c (F-U2-1's ruling): a member's own door defers to the book's.
        case .noteInSealedBook:
            if let verb = roads.bookSeal.verb {
                return "This note is in a book that is \(roads.bookSeal.state) — "
                    + "\(verb) the book to change it."
            }
            return "This note is in a book that is \(roads.bookSeal.state), "
                + "so it can't be changed here."
        // 13i-d U3 — the journal trait's one refusal (the sitting record §10:
        // the daily Journal's marker is constitutive — the 13i-a op's guard,
        // first reachable from a face at the Collecting pane's row).
        // Platform-neutral: names no door.
        case .dailyJournalTraitIsConstitutive:
            return "This is your daily Journal, so its entries are always dated by the day — "
                + "make another book your daily Journal first to change that."
        case .ownedBookDuplicatesDeep:
            return "This book owns its notes, so a duplicate has to carry copies of them — "
                + "duplicate it with copies."
        // 13i-d U1 — the Bookcase's shelves (the sitting record §7/§19/§24).
        // Platform-neutral words: none names a Mac door.
        case .shelfNotFound:
            return "That shelf isn't there any more — nothing changed."
        case .invalidShelfName:
            return "A shelf needs a name."
        case .invalidShelfGlyph(let value):
            return "\u{201C}\(value)\u{201D} can't be a shelf's mark — "
                + "use one character, and no emoji."
        case .wingNotFound:
            return "That library isn't there any more — nothing changed."
        // 13i-d U5 — WINGS (the sitting record §9; R-13id-2; #169(b)).
        // Platform-neutral: none names a door.
        case .invalidWingName:
            return "A wing needs a name."
        case .duplicateWingName(let existing):
            if BookNaming.key(existing) == BookNaming.key(WingWords.home) {
                return "\(WingWords.home) is the built-in wing's name — pick another."
            }
            return "There's already a wing called \u{201C}\(existing)\u{201D} — pick another name."
        case .wingNotEmpty(_, let contents):
            return WingWords.notEmpty(nil, contents)
        case .postAlreadyInWing:
            return "That note is already in that wing — nothing changed."
        case .crossWingMembership:
            return "That note lives in another wing, and a book only holds notes of its own "
                + "wing — move the note here first."
        case .dailyJournalIsHomeOnly:
            return "Your daily Journal lives in \(WingWords.home) — only a \(WingWords.home) "
                + "book can be it."
        // 13i-d U5b — the book and bulk moves (R-13id-6). Platform-neutral.
        case .readingAlreadyInWing:
            return "That book is already in that wing — nothing changed."
        case .wingMoveIntoItself:
            return "Everything is already in that wing — pick another one to move it to."
        case .placementAnchorNotOnShelf:
            return "That book has moved to another shelf — nothing changed."
        // 13i-e U2 — BOOK ARCHIVE (R-13ie-1…4; the sitting record §10's
        // never-hard-delete). Platform-neutral: archive is the one road both
        // faces name, and the daily Journal comes back on its own.
        case .dailyJournalCannotBeDeleted:
            return BookArchiveCopy.cannotDeleteDailyJournal
        case .readingAlreadyArchived:
            return "That book is already archived — nothing changed."
        case .readingNotArchived:
            return "That book isn't archived any more — nothing changed."
        // **VX-362 — THE WIRE'S SWEEP** (the VX-336 run record's U9 SWEEP
        // TABLE, its R/E rows; D3: a refusal her doors can also meet is worded
        // HERE, both platforms' words — the MCP door speaks this table through
        // `MCPHostHooks.refusalWords`). Each reached the wire as the raw case.
        // Platform-neutral: none names a door. (PROVISIONAL P-VX362-1.)
        //
        // `add_note_to_book` on a member — her generic arm's sentence
        // (`ReadingsViewModel.message`), the same words here; that arm stays
        // a one-line forward at its next touch.
        case .alreadyInReading:
            return "That note is already in this book."
        // A note into a book at its `max_posts` — the same arm's sentence.
        case .readingAtCapacity:
            return "This book is at its note limit."
        // `restore_comment` on a live comment — `put_back`'s "That block is
        // already back." twin.
        case .commentNotDeleted:
            return "That comment is already back."
        // A blank chapter name (`import_document`'s book form) — the shelf's
        // and the wing's "A … needs a name." twin.
        case .invalidSectionName:
            return "A chapter needs a name."
        // A note gone between a door's read and its write (a sync apply, a
        // delete in another window) — `variantNotFound`'s first clause, one
        // row-kind up.
        case .containerNotFound:
            return "That note isn't there any more — it may have just been deleted."
        // A book that became a gathering under a door (another device's
        // un-bind) — and the bind door's own direction, hoisted.
        case .wrongReadingKind(_, let expected):
            return expected == .gathering
                ? "That's already a book — only a gathering binds into one."
                : "That isn't a book — a gathering shows the notes its rule matches and holds none of its own."
        // An outflow tag the book's wing doesn't hold (the dangling-wing road
        // `set_book_rule` and her rule editor's Save share — VX-364) — the
        // shelf's and the library's "isn't there any more — nothing changed."
        // twin.
        case .tagNotFound:
            return "That tag isn't there any more — nothing changed."
        // **VX-381 ladder r1 F-3** — the Delete Tag undo's collision refusal
        // (P-VX381-U2-3: a tag she made since holds the path, so the undo
        // refuses and KEEPS its entry). It reached her as `Undo failed:
        // Refused: duplicateTagPath(path: "work")` on the Mac and bare on the
        // phone. The fact in Settings ▸ Tags' own words, then the road. The
        // road is act-less ("try again", not "undo again") because the
        // table cannot know its door: the undo doors frame it ("Undo failed:
        // …"), and the rule editor's make-a-tag door can meet it on a race.
        // Platform-neutral. (PROVISIONAL wording, for the orchestrator.)
        case .duplicateTagPath(let path):
            return "A tag named \u{201C}\(path)\u{201D} already exists \u{2014} rename it, then try again."
        // A deleted block put back while a sync apply left it placed.
        case .blockAlreadyPlaced:
            return "That block is already in a note — nothing changed."
        // A picked block moved out between a door's read and its act —
        // `blockNotPlaced`'s sentence, the same reading.
        case .blockNotInContainer:
            return "That block is no longer in this note — it may have "
                + "moved while you worked. Nothing was changed here."
        default:
            return nil
        }
    }

    /// The table's words, or its fallbacks: an unworded `OperationError`
    /// keeps its name ("Refused: …"), anything else is described.
    static func message(for error: Error, roads: OpsRefusalRoads) -> String {
        if let words = words(for: error, roads: roads) { return words }
        if let error = error as? OperationError { return "Refused: \(error)" }
        return String(describing: error)
    }

    // MARK: - The flush contract's refusal (VM-5 whole-round pass, MINOR 4)

    /// **A door whose act needs the note's pending bytes in the store, when
    /// the flush could not land them** — a refused autosave (a seal or a take
    /// lock that arrived by sync mid-typing) leaves the bytes pending, and an
    /// act that copies or rewrites the note then would act on a store missing
    /// her last words. Names no door, so it is both platforms' words: the
    /// phone's `MobileEditorViewModel.unsavedChangesRefusal` forwards here,
    /// and the shared `VersionActs` speaks it. *(The Mac's structural doors
    /// still carry this sentence as byte-identical literals — pre-existing,
    /// each a one-line forward at its next touch.)*
    static let unsavedChanges =
        "Unsaved changes couldn't be written — resolve that first, then retry."

    // MARK: - The editor GATE's refusals (18m U3, ruling G)

    /// **The editor gate's four refusals, ONE brain for both editors.** Each
    /// view model had its own `message(for:)` — byte-identical but for one
    /// arm — so the gate's vocabulary lived twice. The locked-TAKE line is the
    /// platform's (the phone's names its takes sheet's ⑂ road), and the
    /// cross-block fallback's fan roads are the platform's chord or menu row,
    /// so both arrive as parameters; the other two sentences are the same on
    /// both. Each view model keeps `message(for:)` as a one-line forward.
    static func gateMessage(
        for refusal: BlockRangeIndex.Refusal, lockedTake: String, fanRoads: String
    ) -> String {
        switch refusal {
        case .crossesBlockBoundary:
            // 13j J8(b), her report: *"the reason is really unclear to me why
            // right now."* This case used to name THREE causes at once for a
            // gesture that had exactly one. Both live doors onto it now
            // DIAGNOSE — they hold the range and the slots, so they call
            // `CrossBlockRefusal.message(range:index:slots:fanRoads:)`, which
            // asks which condition actually declined. What remains here is the
            // range-less fallback for any future caller that has neither.
            // **13u2 UNIT C:** it used to speak the boundary residual, which
            // #109's clamp law retired — and a range-less caller could not
            // claim that geometry anyway. The surviving cause says only that
            // the surface has not caught up, which is the honest answer when
            // nobody can name the condition.
            CrossBlockRefusal.message(for: .surfaceNotSettled, fanRoads: fanRoads)
        case .readOnlySlot:
            "This block hasn't fully synced; it is read-only for now."
        case .lockedVariant:
            lockedTake
        case .indexDesync:
            "The editor lost track of block boundaries — reloading from the store."
        }
    }
}
