//
//  ReadingsViewModel.swift
//  Variorum
//
//  Reading CRUD (Phase 10 Step 6): create/rename/delete curated + smart
//  readings, sort-field/direction, the v1 SmartQuerySpec vocabulary, and
//  curated membership add/remove/reorder — every action exactly one
//  Phase 2 operation; the assembly semantics stay Phase 4's.
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import VariorumCore

@MainActor
@Observable
final class ReadingsViewModel {
    @ObservationIgnored private let session: AppSession

    private(set) var readings: [Reading] = []
    private(set) var lastError: String?
    /// 13i-c U4 (§4 row 18): Manage Notes…'s add door's ownership CHOICE —
    /// the one shared road; the sheet presents it.
    @ObservationIgnored let membershipDoors: MembershipDoors

    init(session: AppSession) {
        self.session = session
        self.membershipDoors = MembershipDoors(session: session)
    }

    func start() async {
        // 13i-d U5: the CURRENT WING's books (a book never spans wings).
        do {
            for try await value in session.database.observeReadings(
                wingID: session.wing.currentID) {
                readings = value
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// Internal so tests drive the listing deterministically.
    func adopt(_ new: [Reading]) {
        readings = new
    }

    @discardableResult
    func create(
        name: String, kind: ReadingKind, profile: String? = nil,
        sortField: SortField = .manual, sortDir: SortDirection = .asc,
        // 13i-d U5: nil = the CURRENT wing (every door mints where she is).
        querySpec: String? = nil, wingId: String? = nil,
        // 13i-d U1 — the Bookcase's CONTEXT MINT (§19.1/§24): the solo'd
        // shelf the new book lands on; nil = unshelved (every other door).
        shelfId: String? = nil
    ) async -> String? {
        let wingId = wingId ?? session.wing.currentID
        do {
            let reading = try await session.runner.run { ops in
                // 13e E13 — the duplicate-name guard, INSIDE the runner
                // closure with the mint (her round-3 ruling). Runner bodies
                // are synchronous, so no other door's write can land between
                // the read and the insert; the only surviving race is the
                // cross-device one her ruling deliberately tolerates.
                try ops.assertBookNameIsFree(name)
                // 13i-c (R-13ic-4): a gathering is minted WITH its rule — the
                // op refuses a rule-less one; the shelf's mint sheet drafts the
                // rule inline and keeps Create disabled until it has a term
                // (13i-c U3 — `MintGatheringSheet`).
                return try ops.createReading(
                    name: name, kind: kind, profile: profile,
                    sortField: sortField, sortDir: sortDir, querySpec: querySpec,
                    wingId: wingId, shelfId: shelfId)
            }
            lastError = nil
            return reading.id
        } catch {
            lastError = Self.message(error)
            return nil
        }
    }

    func rename(_ id: String, to name: String) async {
        // E13: `excluding` is this book's own row — renaming a book to the
        // name it already has, or only changing its casing, is not a
        // collision with itself.
        await run { ops in
            try ops.assertBookNameIsFree(name, excluding: id)
            try ops.renameReading(id, name: name)
        }
    }

    // (13i-c ladder round 1, F-U4-8: `delete` RETIRED — the shelf's Delete
    // Book routes through `BookStateDoors.open(.deleteBook)` since U4 (the
    // three-arm confirm: gathering · plain · owned two-choice), and a second
    // road beside the one confirm door is the forked-brains class. The op
    // stays `deleteReading`, the doors' own.)

    func setSort(_ id: String, field: SortField, direction: SortDirection) async {
        await run { ops in try ops.setReadingSort(id, field: field, direction: direction) }
    }

    // (13i-b U3: `setSmartSpec` — the retired `SmartSpecSheet`'s write, in
    // the v1 vocabulary — RETIRED with it. The rule's one face is
    // `RuleEditorModel`, writing the v2 grammar through the same choke
    // point, `setReadingQuerySpec`.)

    // MARK: - Curated membership

    /// Through the one membership road (13i-c U4, §4 row 18): an ownership
    /// refusal OPENS the choice sheet (P-2); any other speaks here.
    func addPost(_ postID: String, to readingID: String) async {
        do {
            try await membershipDoors.addOrOffer(postID, to: readingID)
            lastError = nil
        } catch {
            lastError = Self.message(error)
        }
    }

    func removePost(_ postID: String, from readingID: String) async {
        await run { ops in try ops.removePostFromReading(postID, from: readingID) }
    }

    /// Reorder by one step in MANUAL order: the neighbor comes from the
    /// current assembly (position order), the move is the existing op.
    func movePost(_ postID: String, in readingID: String, up: Bool) async {
        do {
            let entries = try await session.database.read { [readingID] db in
                try Queries.assembleReading(db, readingID: readingID)
            }
            guard let i = entries.firstIndex(where: { $0.postID == postID }) else { return }
            let target: Operations.InsertPosition
            if up {
                guard i > 0 else { return }
                target = .before(entries[i - 1].postID)
            } else {
                guard i < entries.count - 1 else { return }
                target = .after(entries[i + 1].postID)
            }
            try await session.runner.run { ops in
                try ops.reorderReadingPost(postID, in: readingID, to: target)
            }
            lastError = nil
        } catch {
            lastError = Self.message(error)
        }
    }

    private func run(_ body: @escaping @Sendable (Operations) throws -> Void) async {
        do {
            try await session.runner.run(body)
            lastError = nil
        } catch {
            lastError = Self.message(error)
        }
    }

    static func message(_ error: Error) -> String {
        guard let op = error as? OperationError else {
            return "Operation failed: \(error)"
        }
        switch op {
        case .lockedReading:
            return "This book is locked — unlock it first."
        case .alreadyInReading:
            return "That note is already in this book."
        case .readingAtCapacity:
            return "This book is at its note limit."
        case .wrongReadingKind(_, let expected):
            // 13c 2D: the message used to state the CURATED direction only,
            // which read as nonsense on the conversion door's refusal (a
            // curated book asked to convert throws `expected: .gathering`).
            // 13i-b U3: the gathering-direction words are the BIND door's
            // now (the door 13c 2D shipped as "convert").
            return expected == .gathering
                ? "That's already a book — only a gathering binds into one."
                : "Only hand-shaped (curated) books hold a note list you pick by hand."
        case .postNotInReading:
            return "That note isn't in this book."
        // 13e E13 — her round-3 ruling, from the ONE copy home (this
        // function is what the shelf's create/rename AND the navigator's
        // rename both speak; `OpsRefusalCopy` reads the same sentence).
        case .duplicateBookName(let existing):
            return BookNameCopy.refusal(existing: existing)
        case .gatheringRequiresRule:
            return OpsRefusalCopy.message(for: op)
        default:
            return "The operation was refused: \(op)"
        }
    }
}
