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

    init(session: AppSession) {
        self.session = session
    }

    func start() async {
        do {
            for try await value in session.database.observeReadings() {
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
    func create(name: String, kind: ReadingKind) async -> String? {
        do {
            let reading = try await session.runner.run { ops in
                try ops.createReading(name: name, kind: kind)
            }
            lastError = nil
            return reading.id
        } catch {
            lastError = Self.message(error)
            return nil
        }
    }

    func rename(_ id: String, to name: String) async {
        await run { ops in try ops.renameReading(id, name: name) }
    }

    func delete(_ id: String) async {
        await run { ops in try ops.deleteReading(id) }
    }

    func setSort(_ id: String, field: SortField, direction: SortDirection) async {
        await run { ops in try ops.setReadingSort(id, field: field, direction: direction) }
    }

    /// The smart predicate, plainly: encode the v1 vocabulary; nil clears.
    func setSmartSpec(_ id: String, spec: Queries.SmartQuerySpec?) async {
        do {
            let json = try spec.map { try $0.encodedJSON() }
            try await session.runner.run { ops in
                try ops.setReadingQuerySpec(id, querySpec: json)
            }
            lastError = nil
        } catch {
            lastError = Self.message(error)
        }
    }

    // MARK: - Curated membership

    func addPost(_ postID: String, to readingID: String) async {
        await run { ops in try ops.addPostToReading(postID, to: readingID) }
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
            return "This reading is locked — unlock it first."
        case .alreadyInReading:
            return "That post is already in this reading."
        case .readingAtCapacity:
            return "This reading is at its post limit."
        case .wrongReadingKind:
            return "Only curated readings hold a hand-picked post list."
        case .postNotInReading:
            return "That post isn't in this reading."
        default:
            return "The operation was refused: \(op)"
        }
    }
}
