//
//  Takemania.swift
//  Shared (Variorum + VariorumMobile)
//
//  18l-c U6 — TAKEMANIA: the author's test note, minted by a SCRIPTED
//  HISTORY of real operations. Her request, verbatim (the 18l-c kickoff):
//  *"It should come with a decent amount of history and feel like a note
//  that has been edited very heavily — lineage, things released that are on
//  the deletion tray, various different takes, merges and divides have been
//  done, some blocks with takes next to blocks that have no takes, etc."* and
//  *"it should read more like a real document than a tutorial … real history,
//  savepoints, savepoints with names, etc."*
//
//  ── REAL ROWS, NEVER PAINTED ─────────────────────────────────────────────
//  Every row here is written by the operations API her own gestures reach —
//  `createPost`, `newBlock`, `autosave`, `branchVariant`, `newBlankVariant`,
//  `setTakeLabel`, `chooseVariant`, `commit`, `renameCommitPoint`,
//  `archiveVariant`, `divide`, `divideW`, `merge`, `extract`, `deleteBlock`,
//  `closeAutoCommit`, `renameContainer` — on the QUIET facade
//  (`Operations(undoStack: nil)`, the seeders' doctrine: furniture she never
//  placed must never put an inverse on her structural-undo stack). The
//  lineage edges, released originals, tray rows, fans and savepoints are the
//  rows her own hands would have left; nothing downstream can tell the
//  difference, which is the point of a test note.
//
//  ── THE CLOCK (the U6 record's design call 2) ────────────────────────────
//  The book around this note carries 1886 (Sherlock's m6 precedent); THIS
//  note's history runs on a clock RELATIVE TO THE SEED. The note's tray lists
//  only tombstones inside the 30-day Trash window (`Queries.trayBlocks`) and
//  the purge janitor physically removes 30-day tombstone roots — so deletions
//  stamped in 1886 would ship an EMPTY tray and be purged at the first
//  janitor pass. Each step is stamped `anchor − daysAgo + minutes` (three
//  minutes a step): the note is born five weeks before the seed, its
//  sittings land days apart, the deletions fall in its last three weeks (the
//  tray reads 10 … 29 days left at seed), and the last sitting is the day
//  before. Every stamp is in the past.
//
//  ── COMPLETE, OR NOT THERE (the U6 record's design call 3) ───────────────
//  The seeder's discovery is keyed on TITLES, and no app-reachable door runs
//  several operations in one transaction — so the note is created under
//  `workingTitle`, joins the book and wears the tag in its first steps (never
//  bookless, so never in the Pool), writes its whole history inside ONE
//  runner turn (cancellation cannot split it), and takes the title
//  `takemania` as its LAST act. A note stopped halfway is therefore never
//  "present": the seeder's mark is never set over it, and the next occasion
//  trashes it (`SampleLibrarySeeder.seed`'s scripted branch) and mints afresh.
//
//  The prose (`TakemaniaProse`) is Stevenson's — public domain, and her
//  kickoff's *"any amount of using and remixing it is fine"* — lifted from
//  the middle chapters and condensed, with the other takes written the way a
//  person reworking it would try them. No commentary lives inside the note.
//

import Dependencies
import Foundation
import VariorumCore

nonisolated enum Takemania {
    /// Her word for it, exactly — the note's final title (the LAST act).
    static let title = "takemania"
    /// The title the note carries while its history is being written — a
    /// RESERVED name the seeder's discovery recognises as its own half-built
    /// note (the heal: trashed, then minted afresh). Only a stopped seed
    /// ever leaves it visible.
    static let workingTitle = "takemania (unfinished setup)"
    /// The note's chapter in the book, named after the note (the seeder's
    /// one-chapter-per-note shape).
    static let chapter = "takemania"
    /// The quiet chapter it follows in the book's order.
    static let follows = "Story of the Door"

    enum ScriptError: Error, Equatable {
        /// A cut marker was not found in the text it cuts — a script bug the
        /// pins catch long before any reader could.
        case markerMissing(String)
        /// The test seam `interruptAfterStep` stopped the history.
        case interrupted(afterStep: Int)
    }

    /// Mints takemania into the book and returns its note id. Runs inside
    /// ONE runner turn on the quiet facade. `anchor` is the seed's own
    /// "now" (read by the caller from `\.date`, so a pin's clock governs
    /// it). `interruptAfterStep` is the pins' seam for a history stopped
    /// halfway — nil in production.
    static func mint(
        _ ops: Operations, anchor: Date, bookID: String, sectionID: String, tagID: String,
        interruptAfterStep: Int? = nil
    ) throws -> String {
        let script = Script(ops: ops, anchor: anchor, interruptAfter: interruptAfterStep)
        try script.run(bookID: bookID, sectionID: sectionID, tagID: tagID)
        return script.note
    }

    /// The UTF-16 offset of `marker` in `text` — the operations' offset unit.
    static func offset(of marker: String, in text: String) throws -> Int {
        guard let range = text.range(of: marker) else { throw ScriptError.markerMissing(marker) }
        return text[..<range.lowerBound].utf16.count
    }
}

// MARK: - The script's hands

/// One person's sittings, replayed. Holds the clock (which sitting, which
/// minute), the step count (the interruption seam) and the texts the script
/// has written (for the churn delta a real editor would report).
nonisolated private final class Script {
    typealias Placed = (block: String, take: String)

    let ops: Operations
    let anchor: Date
    let interruptAfter: Int?
    private(set) var note = ""
    private var daysAgo: Double = 0
    private var minute = 0
    private var steps = 0
    private var texts: [String: String] = [:]

    init(ops: Operations, anchor: Date, interruptAfter: Int?) {
        self.ops = ops
        self.anchor = anchor
        self.interruptAfter = interruptAfter
    }

    /// One step: counted, stamped three minutes after the last, run under
    /// that stamp (the operations layer's own time seam, `\.date`).
    @discardableResult
    private func at<T>(_ op: () throws -> T) throws -> T {
        if let interruptAfter, steps >= interruptAfter {
            throw Takemania.ScriptError.interrupted(afterStep: steps)
        }
        steps += 1
        minute += 3
        let stamp = anchor.addingTimeInterval(-daysAgo * 86_400 + Double(minute) * 60)
        return try withDependencies({ $0.date = .constant(stamp) }, operation: op)
    }

    /// A sitting: its steps, then leaving the note — the everyday cadence's
    /// quiet savepoint per edited take (`closeAutoCommit`, OverallModel §3).
    private func sitting(daysAgo: Double, startingAt minute: Int, _ body: () throws -> Void) throws {
        self.daysAgo = daysAgo
        self.minute = minute
        try body()
        try at { _ = try ops.closeAutoCommit(note) }
    }

    // MARK: The gestures

    @discardableResult
    private func add(_ text: String) throws -> Placed {
        let minted = try at { try ops.newBlock(in: note, text: text, at: .end) }
        texts[minted.variant.id] = text
        return (minted.block.id, minted.variant.id)
    }

    private func rewrite(_ take: String, _ text: String) throws {
        let old = texts[take] ?? ""
        try at { try ops.autosave(take, text: text, charDelta: old.count + text.count) }
        texts[take] = text
    }

    /// The default gesture: a new take inheriting the source's text, then
    /// rewritten and named.
    private func branch(_ block: String, from source: String, label: String, _ text: String) throws -> String {
        let take = try at { try ops.branchVariant(block, from: source) }.id
        texts[take] = texts[source]
        try rewrite(take, text)
        try name(take, label)
        return take
    }

    /// The other gesture: a genuinely different take, begun blank.
    private func blank(_ block: String, label: String, _ text: String) throws -> String {
        let take = try at { try ops.newBlankVariant(block) }.id
        texts[take] = ""
        try rewrite(take, text)
        try name(take, label)
        return take
    }

    private func name(_ take: String, _ label: String) throws {
        try at { try ops.setTakeLabel(take, label: label) }
    }

    private func choose(_ block: String, _ take: String) throws {
        try at { try ops.chooseVariant(block, variantID: take) }
    }

    /// ⌘S — a deliberate savepoint, named or not.
    @discardableResult
    private func save(_ take: String, _ message: String? = nil) throws -> String {
        try at { try ops.commit(take, kind: .manual, message: message) }.id
    }

    /// Naming a saved moment after the fact (R-13u3-1).
    private func renameSavepoint(_ commit: String, _ message: String) throws {
        try at { _ = try ops.renameCommitPoint(commit, message: message) }
    }

    private func archive(_ take: String) throws {
        try at { try ops.archiveVariant(take) }
    }

    private func delete(_ block: String) throws {
        try at { try ops.deleteBlock(block) }
    }

    /// The everyday divide (one take, in place): the source keeps the first
    /// half, the second is minted after it.
    private func divide(_ placed: Placed, before marker: String) throws {
        let text = texts[placed.take] ?? ""
        let cut = try Takemania.offset(of: marker, in: text)
        let result = try at { try ops.divide(placed.block, cut: cut) }
        texts[placed.take] = BoundarySnapping.seamTrimmedHalves(text, cutAtUTF16: cut)?.first
        texts[result.variant.id] = result.variant.workingText
    }

    private func merge(_ first: String, _ second: String) throws {
        let result = try at { try ops.merge(first, second) }
        texts[result.variant.id] = result.variant.workingText
    }

    // MARK: - The history

    func run(bookID: String, sectionID: String, tagID: String) throws {
        typealias P = TakemaniaProse

        // ── Sitting 1 — five weeks before: the first evening. The will. ──
        var opening: Placed = ("", "")
        var eyesore: Placed = ("", "")
        var candle = "", ifAnyOneKnows = "", oldestFriends = "", friendsYounger = ""
        try sitting(daysAgo: 34, startingAt: 30) {
            note = try at { try ops.createPost(title: Takemania.workingTitle) }.id
            // Never bookless, never untagged — so never in the Pool, even if
            // the history stops here (design call 3).
            try at { _ = try ops.applyTag(tagID, toPost: note) }
            try at { _ = try ops.addPostToReading(note, to: bookID) }
            try at { try ops.assignPostToSection(note, in: bookID, section: sectionID) }
            try add(P.headingWill)
            opening = try add(P.openingV1)
            try add(P.willTerms)
            eyesore = try add(P.eyesoreFirstTry)
            try add(P.madness)
            candle = try add(P.candle).block
            ifAnyOneKnows = try add(P.ifAnyOneKnows).block
            oldestFriends = try add(P.oldestFriends).block
            friendsYounger = try add(P.friendsYounger).block
            try add(P.fanciful)
            try add(P.neverHeardOfHim)
        }

        // ── Sitting 2 — the next evening: Mr. Seek. ──
        var dream: Placed = ("", "")
        var mrSeek = ""
        var fineNight: Placed = ("", "")
        var hydeLeaves: Placed = ("", "")
        try sitting(daysAgo: 33, startingAt: 45) {
            try add(P.headingSeek)
            dream = try add(P.dreamScroll)
            try add(P.hauntTheDoor)
            mrSeek = try add(P.mrSeek).block
            fineNight = try add(P.fineNightWhole)
            try add(P.theExchange)
            hydeLeaves = try add(P.hydeLeavesWithDialogue)
        }

        // ── Sitting 3 — the eyesore gets Stevenson back; Hyde's face. ──
        var eyesoreStevenson = ""
        var hydeFace: Placed = ("", "")
        try sitting(daysAgo: 31, startingAt: 0) {
            try name(eyesore.take, "first try")
            eyesoreStevenson = try branch(
                eyesore.block, from: eyesore.take, label: "Stevenson", P.eyesoreStevenson)
            try choose(eyesore.block, eyesoreStevenson)
            try rewrite(opening.take, P.openingV2)
            try save(opening.take)
            hydeFace = try add(P.hydeFaceStevenson)
            try add(P.pooleAtTheDoor)
        }

        // ── Sitting 4 — the Carew murder, pasted in whole. ──
        var maid: Placed = ("", "")
        var recognition: Placed = ("", "")
        try sitting(daysAgo: 29, startingAt: 60) {
            try add(P.headingCarew)
            maid = try add(P.maidWhole)
            try add(P.twoOClock)
            recognition = try add(P.recognitionStevenson)
            try add(P.fogToSoho)
            try add(P.theRooms)
            try save(maid.take, "the maid, in one piece")
        }

        // ── Sitting 5 — cutting the dream down; a plainer Hyde. ──
        var hydeFacePlainer = ""
        try sitting(daysAgo: 27, startingAt: 20) {
            try save(dream.take, "the whole scroll, before cutting")
            try name(dream.take, "scroll")
            let short = try branch(dream.block, from: dream.take, label: "short", P.dreamShort)
            try choose(dream.block, short)
            try name(hydeFace.take, "Stevenson")
            hydeFacePlainer = try branch(
                hydeFace.block, from: hydeFace.take, label: "plainer", P.hydeFacePlainer)
        }

        // ── Sitting 6 — the maid split in two; the letter drafted. ──
        var oath: Placed = ("", "")
        var guestWine: Placed = ("", "")
        var guestCompares: Placed = ("", "")
        var lockedInTheSafe: Placed = ("", "")
        try sitting(daysAgo: 24, startingAt: 50) {
            try divide(maid, before: P.maidCutMarker)
            try add(P.headingLetter)
            try add(P.theCabinet)
            oath = try add(P.oathStevenson)
            try add(P.theHydeLetter)
            guestWine = try add(P.guestWine)
            guestCompares = try add(P.guestComparesV1)
            lockedInTheSafe = try add(P.lockedInTheSafe)
        }

        // ── Sitting 7 — the fine night divided; Hyde's exit cut short. ──
        try sitting(daysAgo: 22, startingAt: 10) {
            try divide(fineNight, before: P.fineNightCutMarker)
            try name(hydeLeaves.take, "with the dialogue")
            let toTheDoor = try branch(
                hydeLeaves.block, from: hydeLeaves.take, label: "cut to the door", P.hydeLeavesCut)
            try choose(hydeLeaves.block, toTheDoor)
            try save(toTheDoor)
        }

        // ── Sitting 8 — a tighter eyesore; Mr. Seek goes; the opener settles. ──
        try sitting(daysAgo: 20, startingAt: 70) {
            _ = try branch(eyesore.block, from: eyesoreStevenson, label: "tighter", P.eyesoreTighter)
            try delete(mrSeek)
            try rewrite(opening.take, P.openingV3)
            try save(opening.take, "opening, back to Stevenson\u{2019}s rhythm")
        }

        // ── Sitting 9 — the last night, drafted in one go. ──
        var night: Placed = ("", "")
        var malady = "", kettle = "", glass = ""
        var theDoor: Placed = ("", "")
        var ending: Placed = ("", "")
        var endingFirstVersion = ""
        try sitting(daysAgo: 17, startingAt: 0) {
            try add(P.headingLastNight)
            try add(P.pooleVisits)
            night = try add(P.nightStevenson)
            try add(P.theVoice)
            try add(P.changed)
            try add(P.mawsNote)
            try add(P.seenHim)
            malady = try add(P.maladyTheory).block
            try add(P.notMyMaster)
            theDoor = try add(P.doorStevenson)
            try add(P.quietRoom)
            try add(P.theBody)
            try add(P.tooLate)
            kettle = try add(P.kettleAndBook).block
            glass = try add(P.chevalGlass).block
            try add(P.theEnvelope)
            ending = try add(P.endingStevenson)
            try save(theDoor.take, "Stevenson\u{2019}s door, untouched")
            endingFirstVersion = try save(ending.take, "ending, first version")
        }

        // ── Sitting 10 — the candle and the thought become one block. ──
        var oathSavepoint = ""
        try sitting(daysAgo: 15, startingAt: 80) {
            try merge(candle, ifAnyOneKnows)
            oathSavepoint = try save(oath.take)
            _ = try branch(guestWine.block, from: guestWine.take, label: "shorter", P.guestWineShorter)
        }

        // ── Sitting 11 — the oath shortened; the maid given her own voice. ──
        try sitting(daysAgo: 12, startingAt: 40) {
            try renameSavepoint(oathSavepoint, "before the oath gets shorter")
            try name(oath.take, "Stevenson")
            let shorter = try branch(oath.block, from: oath.take, label: "shorter", P.oathShorter)
            try choose(oath.block, shorter)
            try name(maid.take, "Stevenson")
            _ = try branch(maid.block, from: maid.take, label: "the maid tells it", P.maidTellsIt)
        }

        // ── Sitting 12 — the weather tightened; the first try archived; the
        //    letter's last sentence pulled out to stand alone (the extract
        //    OverallModel §7 names: pull the closing sentence out, fan THAT). ──
        var coldBlood: Placed = ("", "")
        try sitting(daysAgo: 10, startingAt: 60) {
            try save(night.take, "first pass at the weather")
            try name(night.take, "Stevenson")
            let tighter = try branch(night.block, from: night.take, label: "tighter", P.nightTighter)
            try choose(night.block, tighter)
            try archive(eyesore.take)
            let text = texts[lockedInTheSafe.take] ?? ""
            let start = try Takemania.offset(of: P.bloodRanCold, in: text)
            let result = try at {
                try ops.extract(lockedInTheSafe.block, span: start..<text.utf16.count)
            }
            texts[lockedInTheSafe.take] = BoundarySnapping.seamTrimmedHalves(
                text, cutAtUTF16: start)?.first
            texts[result.variant.id] = result.variant.workingText
            coldBlood = (result.block.id, result.variant.id)
        }

        // ── Sitting 13 — Guest's fireside goes; the lone sentence fans out. ──
        try sitting(daysAgo: 9, startingAt: 30) {
            try delete(guestWine.block)
            try rewrite(guestCompares.take, P.guestComparesV2)
            try save(coldBlood.take, "keep the blood running cold")
            try name(coldBlood.take, "Stevenson")
            _ = try branch(coldBlood.block, from: coldBlood.take, label: "sat up", P.bloodSatUp)
            _ = try blank(coldBlood.block, label: "one hand", P.bloodOneHand)
        }

        // ── Sitting 14 — the Lanyon exchange merged; Hyde's face divided. ──
        try sitting(daysAgo: 7, startingAt: 70) {
            try merge(oldestFriends, friendsYounger)
            // The fanned block's DEFAULT divide (keep-on-top, U-2 — the
            // `KeepOnTopDivide` shape, composed from divide-W's parking):
            // the displayed take is cut; the other take is cut at its very
            // END, so it rides WHOLE onto the top block; the original is
            // preserved whole behind both successors.
            let displayed = hydeFace.take
            let cut = try Takemania.offset(
                of: P.hydeFaceCutMarker, in: texts[displayed] ?? "")
            let parked = (texts[hydeFacePlainer] ?? "").utf16.count
            let result = try at {
                try ops.divideW(
                    hydeFace.block, cuts: [displayed: cut, hydeFacePlainer: parked],
                    displayedVariantID: displayed)
            }
            if let top = result.first.variants.first {
                try save(top.id, "after the divide: Hyde\u{2019}s face in two")
            }
        }

        // ── Sitting 15 — the malady theory goes; five blows; the stick. ──
        try sitting(daysAgo: 5, startingAt: 50) {
            try delete(malady)
            try name(theDoor.take, "Stevenson")
            let fiveBlows = try branch(
                theDoor.block, from: theDoor.take, label: "five blows", P.doorFiveBlows)
            try choose(theDoor.block, fiveBlows)
            try name(recognition.take, "Stevenson")
            _ = try branch(
                recognition.block, from: recognition.take, label: "the stick first", P.recognitionStick)
        }

        // ── Sitting 16 — the kettle goes; an open ending; a faceless dream. ──
        var openEnding = ""
        try sitting(daysAgo: 3, startingAt: 80) {
            try delete(kettle)
            try name(ending.take, "Stevenson\u{2019}s close")
            openEnding = try branch(ending.block, from: ending.take, label: "open ending", P.endingOpen)
            try choose(ending.block, openEnding)
            _ = try blank(dream.block, label: "no face", P.dreamNoFace)
            try archive(hydeLeaves.take)
        }

        // ── Sitting 17 — yesterday: the glass goes; one more ending. ──
        try sitting(daysAgo: 1, startingAt: 60) {
            try delete(glass)
            _ = try blank(ending.block, label: "Lanyon next", P.endingLanyonNext)
            try renameSavepoint(endingFirstVersion, "ending as Stevenson closes it")
            try save(openEnding, "the open ending, reading it tomorrow")
        }

        // THE LAST ACT — the title (design call 3): until this lands the note
        // is not "takemania" to the seeder's discovery.
        try at { try ops.renameContainer(note, title: Takemania.title) }
    }
}
