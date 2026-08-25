//
//  RecoveryCopy.swift
//  Variorum (shared: Mac + Mobile)
//
//  **THE DELETION STORY'S SENTENCES, HOISTED** (round 2 batch 4 —
//  MobileSoul §3, and the parity inventory's §4(c) row: *"Each file's own
//  comment says the strings live in one home because copy elsewhere
//  promises the surface by name and would drift. That argument does not
//  stop at the platform boundary."*).
//
//  Until this file existed the whole vocabulary lived in Mac app code
//  (`Features/Library/RecoveryView.swift`'s `RecoveryPath`,
//  `Features/Tray/TrayPanel.swift`'s `TrayPath`), so the phone's Trash
//  would have had to re-write every sentence — and the two platforms would
//  then have described one 30-day clock two ways. What moved here is the
//  SEMANTIC-bearing half only, exactly as the inventory scoped it: the
//  clock language, archive-has-no-clock, the kind vocabulary, the
//  count-by-kind Empty-Trash confirm, and the three honest purge-receipt
//  populations. Pure Mac chrome wording (the Library menu item's label,
//  the tray's badge glyph and door phrase) stays where it was.
//
//  `RecoveryPath` and `TrayPath` now FORWARD here, so the Mac's pins ride
//  unmodified (the 3C parity pattern) and a rename lands once.
//
//  The Trash-row → purge-root table mapping moved with the words because it
//  is the same one brain, not chrome (its own comment used to promise the
//  phone "its own twin" — the drift class).
//
//  **13l Act 2 (A1-NIT-1's sibling, A1-NIT-2): the ACTS moved OUT.** The
//  first-act cold review named the shape — a `…Copy` file carrying two
//  `@MainActor` act compositions beside the sentences — and its disposition
//  said they should split "when that item grows the decision layer". Item 4
//  grew it, so `TrashPutBack`, `PreservedOriginPutBack`, `RecoveryRefusal`
//  and `DeletionRefusal` now live in `Shared/RecoveryActs.swift` with the
//  purge layer. This file is sentences again.
//

import Foundation
import VariorumCore

/// The deletion story's shared vocabulary. Every sentence here is about
/// what the STORE does — the 30-day window, archive's absence of a clock,
/// what a purge takes — which is why neither platform may own it alone.
nonisolated enum RecoveryCopy {
    // MARK: The two sections (they must never blur — her round-3 ruling)

    /// **The Trash** (13j J1, her word). One listing over every deleted
    /// thing, on the 30-day clock.
    static let trashSection = "Trash"
    /// The other half: kept forever, no clock, deliberately calm.
    static let archivedSection = "Archived"
    /// The surface that holds both, named the same on both platforms.
    ///
    /// **The MAC has split it** (the post-13l polish round, ledger rows 7–8 —
    /// her B2 direction: *"archived should be a different item on the left
    /// (like where library is, but it says archived)… separating archive and
    /// trash more makes sense"*). There, Archived is its own sidebar surface
    /// and the Trash is its own, reached by the Library's trash icon; the
    /// Mac's `RecoveryPath.menuLabel` names the Trash plainly and nothing
    /// reads this constant any more.
    ///
    /// It stays for the PHONE, whose recovery surface still holds both lists
    /// — a face, and mobile's own round to move. **A parity note rides the
    /// closeout**; the split is what the phone owes, not a second name.
    static let surfaceName = "Archived & Deleted"

    /// The one verb, whatever kind the row is, wherever it is offered.
    static let putBackVerb = "Put back"

    /// How the Trash explains itself in one line — the promise stated where
    /// she can read it, because a countdown with no sentence is a threat.
    static let windowNote =
        "Deleted things wait here for \(TrashWindow.days) days, then they're gone."

    // MARK: The kind vocabulary

    /// The kind filter's words (plural).
    static func kindLabel(_ kind: Queries.TrashItem.Kind) -> String {
        switch kind {
        case .note: return "Notes"
        case .book: return "Books"
        case .block: return "Blocks"
        case .take: return "Takes"
        case .preservedOriginal: return "Originals"
        }
    }

    // MARK: The filter says so (the post-13l polish round, ledger row 2 —
    // her A2 ruling on the 13l walk's P-5(b): *"it can say the trash is
    // empty, but there should be a filters applied chip or something of the
    // sort to make it clear"*)

    /// **The chip.** A kind filter narrows the listing IN SQL, so an empty
    /// result under a filter looks exactly like an empty Trash — and the
    /// walk met precisely that: **Notes** selected, nothing shown, "The Trash
    /// is empty", with blocks sitting in it. The chip is the standing signal
    /// that the view is narrowed; clicking it clears the filter, so the
    /// signal is also the way out (P-2 — a rendered door acts).
    static func filterAppliedChip(_ kind: Queries.TrashItem.Kind) -> String {
        "filter: \(kindLabel(kind)) \u{2715}"
    }

    static let filterAppliedHelp =
        "The listing is narrowed to one kind — click to show everything again."

    /// **The empty state, told the truth about itself.** Three readings, and
    /// only one of them is "the Trash is empty":
    ///
    /// - no filter → the Trash really is empty;
    /// - a filter, and nothing else is waiting either → still empty, honestly
    ///   (the chip alone says the view is narrowed);
    /// - a filter, with other kinds waiting → NOT empty, and the sentence
    ///   says which two facts are true at once.
    ///
    /// `holdsOtherKinds` is the UNFILTERED truth, which a filtered listing
    /// cannot supply — that is the whole defect, so it is a parameter rather
    /// than something derived here.
    static func trashEmptyLine(
        filteredBy kind: Queries.TrashItem.Kind?, holdsOtherKinds: Bool
    ) -> String {
        guard let kind, holdsOtherKinds else { return "The Trash is empty." }
        return "No \(kindLabel(kind).lowercased()) in the Trash — the "
            + "\(kindLabel(kind)) filter is on, and other things are waiting here."
    }

    /// What ONE row calls itself, in the singular.
    static func rowKind(_ kind: Queries.TrashItem.Kind) -> String {
        switch kind {
        case .note: return "note"
        case .book: return "book"
        case .block: return "block"
        case .take: return "take"
        case .preservedOriginal: return "preserved original"
        }
    }

    // MARK: The clock

    /// **The countdown** (13j J1 — 30 days, her fixed window). Deleted rows
    /// wear it; ARCHIVED rows never do, which is the whole reason the two
    /// states are shown apart.
    static func daysLeftLabel(_ days: Int) -> String {
        switch days {
        case 0: return "leaves today"
        case 1: return "1 day left"
        default: return "\(days) days left"
        }
    }

    /// What an ARCHIVED row says instead of a countdown.
    static let archivedForever = "kept — no clock"

    /// **The stranded original's label** (her round-8b ruling): an original
    /// whose whole descendant family is in the Trash rides the family's
    /// clock, and says so where she can see it.
    ///
    /// **Reworded for G3** (the post-13l polish round, ledger row 18 — the
    /// PRESENTATION half of her fold question, *"why do we have unplaced as
    /// separate from archived?"*). The semantic fold is declined at the
    /// ledger row and the reason is recorded there; what folds completely is
    /// how it READS: a preserved original was set aside automatically by a
    /// divide or a merge, and it is kept until its family goes. The old
    /// sentence led with the internal noun and left the "why" to be guessed.
    static let goesWithItsFamily =
        "set aside by a divide or merge \u{2014} kept until its family goes"

    // MARK: THE NOTE'S OWN TRAY — its three sections (the post-13l polish
    // round, ledger rows 9 and 20: her C1 move to the side panel and her G5
    // *"honest trash section"*)

    /// **Archived blocks — kept, forever, no clock** (lifecycle row B1: the
    /// note's tray only, never a global surface).
    ///
    /// It used to share a header with the deleted ones (*"Deleted &
    /// archived"*), which asked her to hold the difference between a
    /// forever-list and a countdown inside one section. Her B2 ruling split
    /// exactly that pair one level up — *"separating archive and trash more
    /// makes sense"* — and the same argument is true inside a note.
    static let trayArchivedSection = "Archived \u{2014} kept, no clock"

    /// **The leaving section** (her G5 ruling, verbatim: *"the tray of a note
    /// should have an honest trash section with everything being deleted, so
    /// it's never a surprise… so you can always see a list of what will be
    /// deleted"*). Everything of THIS note that is on the 30-day clock.
    static let trayLeavingSection = "Leaving \u{2014} on the \(TrashWindow.days)-day clock"

    /// The one line under that header: what the section is FOR. Her word was
    /// *"never a surprise"*, and a section that lists three different kinds of
    /// thing owes one sentence saying so.
    static var trayLeavingExplainer: String { trayLeavingExplainer(.post) }

    /// The scraps area composes the same panel over a pool, so the sentence
    /// takes the home's kind rather than calling a scraps area a note (13l
    /// row 26's rule, which this whole family now keeps).
    static func trayLeavingExplainer(_ home: ContainerKind) -> String {
        "Everything this \(homeWord(home)) has on the clock: blocks it deleted, "
        + "takes deleted on their own, and originals riding a family's "
        + "countdown. Put back keeps a row; \(deleteNowVerb) ends its days early."
    }

    /// The tray's empty states, in the home's own noun.
    static func trayNothingArchived(_ home: ContainerKind) -> String {
        "Nothing archived from this \(homeWord(home)). Archiving a block keeps "
        + "it here with no countdown."
    }

    static func trayNothingLeaving(_ home: ContainerKind) -> String {
        "Nothing from this \(homeWord(home)) is on the clock."
    }

    /// The reveal's arrival-time explanation (`TrayViewModel.revealMissing`).
    static func trayRevealMissing(_ home: ContainerKind) -> String {
        "The block you asked to see isn't in this \(homeWord(home))'s tray."
    }

    /// The takes disclosure's label — **collapsed by default** (her *"albeit
    /// maybe not shown by default"*), and it carries the count either way,
    /// because a fold that hides its own size is not an audit.
    static func trayTakesDisclosure(_ count: Int) -> String {
        count == 1 ? "1 deleted take" : "\(count) deleted takes"
    }

    /// A take row NAMES ITS BLOCK (her A3 discipline: *"a deleted take
    /// definitely needs to name both note & block or it's kinda useless"* —
    /// the note is the panel, so the row owes the block).
    static func trayTakeInBlock(_ blockHandle: String) -> String {
        "in \(blockHandle)"
    }

    /// A take that has no label of its own says what it is, in the take's own
    /// noun — the `BlockPastCopy.emptyTake` lesson, which caught an empty take
    /// calling itself a block.
    static let emptyTakeLabel = "(empty take)"

    // MARK: Put-back receipts (the three landings)

    static let putBackWhereItWas = "Put back where it was."
    static let putBackBeside = "Put back where it came from."

    /// **WHAT A BLOCK CAME OUT OF, IN THE APP'S OWN WORDS** (13l Act 2,
    /// ledger row 26). A block does not only live in a note: the scraps area
    /// is a `kind='pool'` container holding ordinary blocks, and its blocks
    /// reach the Trash by the same road. These two receipts said "note"
    /// whatever the row was, which is the one lie the recovery story cannot
    /// afford (§8d — intuitive from every door). The word comes from the
    /// LANDING now (`Operations.BlockRestoreLanding.home`), which is the
    /// transaction's own answer, never a projection's.
    ///
    /// "scraps" and not "pool": the SURFACE is named Scraps everywhere she
    /// can see it (the row's own "Open scraps" door, the Blocks area), and
    /// "pool" is the model's word (R29 gave the sidebar's Pool to bookless
    /// NOTES, which is a different thing entirely — copy that said "pool"
    /// here would point her at the wrong room).
    static func homeWord(_ home: ContainerKind) -> String {
        switch home {
        case .post: return "note"
        case .pool: return "scraps"
        }
    }

    static func putBackAtEnd(_ home: ContainerKind) -> String {
        switch home {
        case .post: return "Put back at the end of this note."
        case .pool: return "Put back at the end of the scraps."
        }
    }

    /// The block is live again but has nowhere to land (its home is gone, or
    /// it remembers none). **A RECEIPT — something really happened.** Never a
    /// refusal: see `originalHasNoNote` below, which is the sentence for the
    /// case where nothing happened at all.
    ///
    /// **"unplaced" left these sentences at G3** (the post-13l polish round,
    /// ledger row 18 — her fold question's presentation half): the word is
    /// the MODEL's ("a live block with no placement"), it appears nowhere she
    /// could have learned it, and the room it once named was removed at 13j
    /// J6. The queries keep their names — `unplacedBlocks`, `unplacedOrigins`
    /// are code — and no user-facing string says it any more.
    static func putBackUnplaced(_ home: ContainerKind?) -> String {
        guard let home else {
            return "Put back \u{2014} but it remembers no note to go back into, "
                + "so it's set aside on its own for now."
        }
        return "Put back \u{2014} but its \(homeWord(home)) is gone, so it's set "
            + "aside on its own for now."
    }

    /// **The preserved original with no note to go back INTO** (batch 4.5b —
    /// §49's MINOR: *a success sentence in the red slot*). Putting a
    /// preserved original back means PLACING it, and placing needs a note;
    /// with none recorded there is nowhere to put it, so nothing happens.
    /// The shipped code answered that case with `putBackUnplaced` — a
    /// RECEIPT, rendered in the red slot, reading as though the block had
    /// been recovered when it had not moved at all.
    static let originalHasNoNote =
        "This original's note is gone, so there's nowhere to put it back — "
        + "it stays here."
    /// The one refusal either recovery surface needs in its own voice: the
    /// listing still opens under a seal (reading is free); it is putting
    /// back that the seal refuses.
    static let sealedPutBackRefusal =
        "This note is marked complete — unseal it to put this back."

    // MARK: The purge doors (in-Trash only, forever — her round-3 rider)

    static let deleteNowVerb = "Delete Now"
    static let emptyTrashVerb = "Empty Trash…"

    /// Delete Now's confirm, per row — destructive, unrecoverable, asked
    /// EVERY time by her round-10 ruling (there is no don't-ask state
    /// anywhere in the code, and none may be added).
    ///
    /// **IT NAMES WHAT THE ROW IS, AND WHAT IT LEAVES BEHIND** (the ladder's
    /// LR1-4, wording half). Two ways the sentence used to be blind:
    ///
    /// - a saved moment IS a `.note`-kind row (one road, one door set — the
    ///   whole reason the versions family needed no new machinery), so its
    ///   confirm called it *"this note"*. The door-shows-what-it-takes
    ///   principle (G6) is about what the sentence SAYS as much as what the
    ///   act does, and the Trash's own grouping one line away calls it a
    ///   saved version;
    /// - a NOTE's Delete Now does not take its saved versions with it: the
    ///   purge family expands a container into its own blocks and rows, never
    ///   into other containers. They stay in the Trash on the clock they
    ///   already have. Saying so is the same principle from the other end —
    ///   the door naming what it does NOT take.
    ///
    /// Both parameters default, so every shipped caller and pin reads
    /// byte-identically (batch 6's `versions:` precedent).
    ///
    /// *(What is deliberately NOT claimed here: those version rows lose their
    /// note's NAME once the note's blocks are physically gone, because the
    /// link they are grouped by rode those blocks. Taking them WITH the note
    /// is the honest repair and it lives in `PurgeFamily` — `Sync/`-fenced
    /// this round, and carried to its owning phase in KnownIssues.)*
    static func deleteNowConfirm(
        _ kind: Queries.TrashItem.Kind, isVersion: Bool = false, savedVersions: Int = 0
    ) -> String {
        let noun = isVersion ? VersionsPath.trashRowKind : rowKind(kind)
        var sentence = "Delete this \(noun) for good? It skips the rest of its "
            + "\(TrashWindow.days) days — there's no putting it back."
        if savedVersions > 0 {
            let one = savedVersions == 1
            sentence += " Its \(savedVersions) saved version\(one ? "" : "s") "
                + "\(one ? "isn't" : "aren't") taken with it — "
                + "\(one ? "it stays" : "they stay") in the Trash with the "
                + "\(TrashWindow.days) days \(one ? "it has" : "they have") left."
        }
        return sentence
    }

    /// Empty Trash's confirm NAMES THE FULL COUNT BY KIND (her round-8
    /// ruling). Preserved originals are named when they ride: they are the
    /// round-8b passengers, never separately purged.
    ///
    /// **AND IT NAMES WHAT IT DOES NOT TAKE** (the post-13l polish round,
    /// ledger row 21 — her G6 ruling, which SUPERSEDES 13j round-8's
    /// "everything, always"): *"a deleted take on a living block might be the
    /// one item a user does want to keep… I just don't think a 'delete
    /// everything' button in the trash should delete items that aren't being
    /// shown."* Takes no longer row in the Trash (D1), so the door no longer
    /// takes them — the door-shows-what-it-takes principle, in both
    /// directions.
    ///
    /// **The honesty caveat is not optional**, and it is her own word on the
    /// clock (*"i don't want it to be clock exempt"*): sparing is NOT keeping.
    /// A spared take still runs out its own 30 days; putting it back is the
    /// only road that keeps it. Saying "N takes stay" and stopping there
    /// would be the reassuring half of a true sentence, which is the class
    /// the J8 bar exists to refuse.
    ///
    /// The take count still arrives in `counts` — the ask-time read counts
    /// everything the store holds — and this is the ONE place that decides
    /// what each kind's number MEANS.
    /// **AND IT NAMES SAVED VERSIONS APART FROM NOTES** (the post-13l polish
    /// round, batch 6 — the architect's adjudication of batch 5's PROVISIONAL
    /// 3). A version IS a `.note`-kind row and it DOES go, so the total was
    /// never wrong — but *"3 notes go for good"* over two notes and one of
    /// their saved moments hides the very distinction the Trash's grouping
    /// draws one line below it, and the door-shows-what-it-takes principle
    /// (G6) is about what the sentence SAYS as much as what the act does.
    ///
    /// `versions` is a defaulted parameter deliberately: a Trash holding no
    /// moments reads byte-identically to what shipped, so every ordinary
    /// emptying — and every pin that asserts one — is untouched.
    static func emptyTrashConfirm(
        _ counts: [Queries.TrashItem.Kind: Int], versions: Int = 0
    ) -> String {
        let total = counts
            .filter { TrashScope.emptyTrashTakes($0.key) }
            .values.reduce(0, +)
        guard total > 0 else { return "The Trash is empty — nothing to delete." }
        let order: [Queries.TrashItem.Kind] = [.note, .block, .book]
        var parts = order.compactMap { kind -> String? in
            // The notes' number is the notes' own: the moments are counted
            // beside them, never inside them.
            let raw = counts[kind] ?? 0
            let count = kind == .note ? max(0, raw - versions) : raw
            guard count > 0 else { return nil }
            let word = kindLabel(kind).lowercased()
            let singular = rowKind(kind)
            return count == 1 ? "1 \(singular)" : "\(count) \(word)"
        }
        if versions > 0 {
            let phrase = versions == 1
                ? "1 \(VersionsPath.trashRowKind)"
                : "\(versions) \(VersionsPath.trashRowKind)s"
            // Beside the notes, in the place the reader looks for them: a
            // moment belongs to a note, so it is read right after one.
            let afterNotes = (counts[.note] ?? 0) - versions > 0 ? 1 : 0
            parts.insert(phrase, at: min(afterNotes, parts.count))
        }
        var sentence = "Empty the Trash? \(total) thing\(total == 1 ? "" : "s") "
            + "go\(total == 1 ? "es" : "") for good: \(parts.joined(separator: ", "))."
        if let originals = counts[.preservedOriginal], originals > 0 {
            sentence += " \(originals) preserved original\(originals == 1 ? " rides" : "s ride") along with "
                + "\(originals == 1 ? "its" : "their") famil\(originals == 1 ? "y" : "ies")."
        }
        if let takes = counts[.take], takes > 0 {
            sentence += " \(takes) deleted take\(takes == 1 ? "" : "s") on living blocks "
                + "stay\(takes == 1 ? "s" : "") — but not kept: "
                + "\(takes == 1 ? "it" : "each") still runs out its own "
                + "\(TrashWindow.days) days, and putting "
                + "\(takes == 1 ? "it" : "one") back is what keeps it."
        }
        return sentence
    }

    /// The receipts tell the truth about NOW vs the janitor (the J8 bar):
    /// the row left every surface the moment the intent was written; the
    /// bytes follow once every device on the account has seen the deletion.
    /// The three populations are synced · never-synced · signed-out-with-
    /// synced-history (13j ladder B, B3 + R2-M1).
    static func deleteNowReceipt(
        _ kind: Queries.TrashItem.Kind, synced: Bool, familyEverSynced: Bool = false
    ) -> String {
        if synced {
            return "The \(rowKind(kind)) is gone from the app now — the bytes follow "
                + "once every synced device has caught up."
        }
        if familyEverSynced {
            return "The \(rowKind(kind)) is gone from the app now — it once synced, "
                + "so the bytes finish clearing after you next sign in."
        }
        return "The \(rowKind(kind)) is gone from the app now — the app's own "
            + "cleanup removes the bytes."
    }

    /// `versions` names the moments among what went (batch 6's rider, the
    /// confirm's twin): the receipt of a destructive act should read back the
    /// same populations the question named. Defaulted, so a Trash with no
    /// moments in it reads exactly as it shipped.
    static func emptyTrashReceipt(
        _ total: Int, synced: Bool, anyFamilyEverSynced: Bool = false,
        versions: Int = 0
    ) -> String {
        let moments = versions > 0
            ? ", \(versions) of them saved version\(versions == 1 ? "" : "s")"
            : ""
        let head = "The Trash is emptied — \(total) thing\(total == 1 ? "" : "s")\(moments) gone from the app now; "
        if synced { return head + "the bytes follow once every synced device has caught up." }
        if anyFamilyEverSynced {
            return head + "anything that once synced finishes clearing after you "
                + "next sign in; the rest the app cleans up now."
        }
        return head + "the app's own cleanup removes the bytes."
    }

    // MARK: Move-to-Trash (the ordinary deletion doors' promise)

    /// **What "Delete" means everywhere OUTSIDE the Trash** — a tombstone,
    /// recoverable for the window. Round 2 batch 4's own sentences, born
    /// shared because the phone built the doors first and the Mac's 13l
    /// work will want the same words (its note-delete door carries no
    /// confirmation at all today — the inventory's R1 finding).
    ///
    /// **ONE NOUN FOR ONE ROAD** (the post-13l polish round, ledger row 5 —
    /// her A5 ruling on the 13l walk's P-9: *"should be fixed"*). The
    /// sentence used to end *"You can put it back from **Archived & Deleted**
    /// until then"* while it had already said **Trash** — both names are
    /// real (the Trash is a section inside that surface) and the sentence was
    /// honest, but it asked the reader to hold two nouns for one road, in a
    /// confirm she reads while deciding whether to delete her writing. The
    /// place is named ONCE and the second clause points back at it.
    ///
    /// "the Trash" is the forward-compatible half deliberately: this round's
    /// IA pass gives the Trash its own icon door in the Library and retires
    /// the ⋯ menu that "Archived & Deleted" labels, so a sentence built on
    /// `surfaceName` would have to be rewritten again.
    static func moveToTrashDetail(_ kind: Queries.TrashItem.Kind) -> String {
        "The \(rowKind(kind)) goes to the \(trashSection) for \(TrashWindow.days) days. "
            + "You can put it back from there until then."
    }

    /// **ARCHIVING A NOTE SAYS WHERE IT WENT** (the post-13l polish round,
    /// ledger row 25 — the review pass's FOUND-ITEM 2: *"the archive-a-note
    /// door's home has never been walked"*). The door existed and acted in
    /// silence, which on a surface that then removes the note from the
    /// Library reads exactly like a deletion. It names the surface — and the
    /// absence of a clock, because that is the whole difference between this
    /// verb and the one beside it (N3's lifecycle row: archive is available
    /// forever and rides no deletion).
    static let archivedNoteReceipt =
        "Note archived — it's kept in \(archivedSection), with no countdown."

    /// The inverse, said the same way — the note is back where she looks for
    /// it (N3's lifecycle row: Unarchive → Library).
    static let unarchivedNoteReceipt =
        "Note unarchived — it's back in the Library."

    static func archivedNotesReceipt(_ count: Int) -> String {
        count == 1
            ? archivedNoteReceipt
            : "\(count) notes archived — they're kept in \(archivedSection), "
                + "with no countdown."
    }

    /// Deleting a BOOK is not deleting its notes — the 13j books lesson,
    /// fixed at her instruction, said in the door that does it.
    static let deleteBookKeepsItsNotes =
        "Its notes stay in the library."

    static func movedToTrashReceipt(_ kind: Queries.TrashItem.Kind) -> String {
        "\(rowKind(kind).prefix(1).uppercased())\(rowKind(kind).dropFirst()) moved to the "
            + "\(trashSection) — \(TrashWindow.days) days to put it back."
    }

    // MARK: The NOTE-deletion door set (13l Act 2, ledger item 3 — her
    // post-13j ruling: *"include delete note in the note menu with
    // confirmation, … add a confirmation for the library door of deletion,
    // and … allow for command clicking to select multiple items and deleting
    // all of them"*)

    /// **THE MENU LABEL, HOISTED.** These three were `MobileEditorViewModel`
    /// statics, and this file's own comment already said why they should not
    /// be: they were *"born shared because the phone built the doors first and
    /// the Mac's 13l work will want the same words"*. The Mac cannot import a
    /// `VariorumMobile` file, so "want the same words" had exactly two
    /// endings — a hoist, or a second copy of the sentence that describes one
    /// 30-day clock. The phone's statics now forward here (MobileSoul §3: a
    /// Mac phase touching a brain hoists it then).
    static let deleteNoteTitle = "Delete Note\u{2026}"
    /// The confirm's own title. Deliberately NOT a question for the single
    /// case: the detail below carries the whole promise, and a title that
    /// asks while the body answers reads as two questions.
    static let deleteNoteConfirmTitle = "Delete Note"
    static var deleteNoteConfirmDetail: String { moveToTrashDetail(.note) }

    /// **The BULK confirm names the count** — her ruling's letter (*"ONE
    /// confirmation naming the count ('Delete 5 notes?')"*), which is why
    /// this one IS a question: the number is the fact she is being asked to
    /// check, and it belongs where she reads first.
    static func deleteNotesConfirmTitle(_ count: Int) -> String {
        count == 1 ? deleteNoteConfirmTitle : "Delete \(count) notes?"
    }

    static func deleteNotesConfirmDetail(_ count: Int) -> String {
        guard count != 1 else { return deleteNoteConfirmDetail }
        // ONE noun, exactly as the singular above (ledger row 5).
        return "The \(count) notes go to the \(trashSection) for \(TrashWindow.days) days. "
            + "You can put them back from there until then."
    }

    /// ONE receipt for the whole gesture (her ruling's second half), and it
    /// says the same two facts the singular one does: where they went, and
    /// how long there is to change her mind.
    static func movedToTrashReceipt(notes count: Int) -> String {
        guard count != 1 else { return movedToTrashReceipt(.note) }
        return "\(count) notes moved to the \(trashSection) — "
            + "\(TrashWindow.days) days to put them back."
    }

    /// Every named note was already gone (the double-press / racing-window
    /// case). Nothing happened, so this is a refusal's voice, not a receipt's
    /// — it goes where `DeletionRefusal`'s sentences go.
    static func notesAlreadyGone(_ count: Int) -> String {
        count == 1 ? "That note is already gone." : "Those notes are already gone."
    }

    /// **A scraps area is not a note, and the delete act says so** (13l Act 7
    /// — the 8d walk's find).
    ///
    /// The walk fired `Delete Note…` from the scraps editor's `note ▾` menu
    /// and watched the pool tombstone: the confirm promised the Trash, the
    /// receipt said *"Note moved to the Trash — 30 days to put it back"*, and
    /// then nothing listed it — `Queries.trash`'s note arm is fenced to
    /// `kind = 'post'`, its blocks were cascade victims (never listed by
    /// design), and no door anywhere calls `restoreContainer` on a pool. 28
    /// scraps left the app with no way back, under a promise of recovery.
    ///
    /// The fence lives at the ACT because every one of the four doors passes
    /// through it. **Hiding the door on a pool pane is the P-2 half and is
    /// deliberately NOT built here** — it needs the editor's pane to publish
    /// its container kind, and what that surface should offer INSTEAD (a
    /// recoverable "delete the scraps area", or nothing at all) is a product
    /// call. It is on the walk's propose-only list.
    ///
    /// **HER RULING (#77(a), the post-13l polish round — ledger row 32):
    /// NAME THE ROAD INSTEAD.** The shipped sentence said what the act would
    /// not do and stopped there, which leaves someone who wants the scraps
    /// gone with a refusal and no next step. Hers says what to do instead, in
    /// her own shape: *"Scraps go one at a time — delete the scraps
    /// themselves."* The fence itself is unchanged (it lives at the ACT, so
    /// every one of the four doors passes through it); this is what it says.
    static let notADeletableNote =
        "Scraps go one at a time — delete the scraps themselves."

    // MARK: Put-back receipts, by kind and by landing (hoisted at 4.5b)

    /// What a put-back says when the op reports no landing of its own.
    static func putBackReceipt(_ kind: Queries.TrashItem.Kind) -> String {
        "\(rowKind(kind).prefix(1).uppercased())\(rowKind(kind).dropFirst()) put back."
    }

    /// **`restoreBlock` ANSWERS where it landed, and the receipt repeats the
    /// answer rather than guessing** (13j's F2 shape). The three landings,
    /// in the one home — this used to be a `MobileTrashModel` static while
    /// the Mac discarded the landing entirely, which is the drift §49's
    /// MAJOR names.
    ///
    /// **13l Act 2 (ledger row 26): the landing now also answers WHAT it went
    /// back into**, and this is the one place that turns that answer into a
    /// word — so the Trash, the note's tray and the phone cannot describe one
    /// scrap three ways. `.itsOldPlace` needs no kind: "where it was" is true
    /// of every home there is.
    static func landingReceipt(_ landing: Operations.BlockRestoreLanding) -> String {
        switch landing {
        case .itsOldPlace: return putBackWhereItWas
        case .endOfNote(let home): return putBackAtEnd(home)
        case .unplaced(let home): return putBackUnplaced(home)
        }
    }

    /// **`restoreVariant` ANSWERS what came back, and the take's receipt
    /// repeats the answer instead of assuming the fan** (13l Act 1, the
    /// first-act cold review's A1-MAJOR-1 — `landingReceipt`'s shape, one op
    /// over, and the THIRD door to adopt it).
    ///
    /// The restore is an EXACT FLIP (#68(b), ruled), so a take that was
    /// ARCHIVED when it was deleted comes back archived — into its block's
    /// archived listing, never the fan. That row is reachable from the Trash
    /// today: `deleteVariant` accepts an archived, unlocked, non-chosen take
    /// (I10's guard counts only ACTIVE takes, so `ensureNotLastActive`
    /// returns early), and `Queries.trash` lists deleted takes with NO status
    /// filter. The shipped road wrote `_ = try ops.restoreVariant(…)` and
    /// fell through to the generic `putBackReceipt(.take)`, so this surface
    /// said *"Take put back."* while the take landed somewhere she would not
    /// look — the same discard `BlockPastCopy.restored` (the block's History
    /// face) and `LensFallbackCopy.restoredDeletedButArchived` (a lens's
    /// dangling pick) were each corrected for at 13j ladder A's A3. Two doors
    /// onto one act answering *"where did it go?"* two ways is the M-C drift
    /// class the 4.5b hoist exists to kill.
    static func takeRestoredReceipt(_ status: VariantStatus) -> String {
        status == .archived ? takeRestoredArchived : putBackReceipt(.take)
    }

    /// The archived edition. Its two siblings word the same fact for the
    /// surface each speaks on; this is the Trash's, and it is the one BOTH
    /// platforms read.
    static let takeRestoredArchived =
        "Take put back — it was archived when it was deleted, so it's among "
        + "its block's archived takes, not the fan. Unarchive it there to "
        + "bring it back."
}

/// The Trash-row → purge-root table mapping. **Hoisted with the words**
/// (round 2 batch 4): it lived beside the Mac's only renderer, and its own
/// comment promised the phone "its own twin", which is the six-brains drift
/// class stated as a plan. One mapping, both platforms.
extension Queries.TrashItem.Kind {
    nonisolated var purgeTable: String {
        switch self {
        case .note: return "container"
        case .book: return "reading"
        case .block: return "block"
        case .take: return "variant"
        case .preservedOriginal: return "block"  // rides its family; no own door
        }
    }
}
