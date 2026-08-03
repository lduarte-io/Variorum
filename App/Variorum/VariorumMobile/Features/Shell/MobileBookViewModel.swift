//
//  MobileBookViewModel.swift
//  VariorumMobile
//
//  Mobile Stage 3, batch 1 — a book's note list (M7: tapping a book opens
//  its notes; the Read flow itself is S4's). ONE held observation delivers
//  the book row + its assembly coherently (the standing reading-assembly
//  read: curated order or the smart predicate, chapters resolved to
//  section names in book order). Bounded like every held listing
//  (window + probe row, so an exact-window book never false-positives
//  the truncation marker — the Phase 10 discipline).
//
//  Chapters honored (scope item 1): rows group by the assembly's OWN
//  section transitions — the phone never re-sorts, so chapter headers
//  appear exactly where the book's order puts them.
//

import Foundation
import GRDB // AsyncValueObservation iteration (member import visibility)
import Observation
import VariorumCore

@MainActor
@Observable
final class MobileBookViewModel {
    @ObservationIgnored private let session: AppSession
    @ObservationIgnored let readingID: String
    /// The bounded window (P1); the fetch carries one probe row past it.
    @ObservationIgnored private let window: Int

    private(set) var reading: Reading?
    private(set) var entries: [Queries.ReadingEntry] = []
    private(set) var truncated = false
    private(set) var lastError: String?

    init(session: AppSession, readingID: String, window: Int = 300) {
        self.session = session
        self.readingID = readingID
        self.window = window
    }

    nonisolated struct Snapshot: Equatable, Sendable {
        var reading: Reading?
        var entries: [Queries.ReadingEntry]
    }

    func start() async {
        do {
            let id = readingID
            let probe = window + 1
            for try await value in session.database.observe({ db in
                Snapshot(
                    reading: try Reading.fetchOne(
                        db,
                        sql: "SELECT * FROM reading WHERE id = ? AND deleted_at IS NULL",
                        arguments: [id]),
                    entries: try Queries.assembleReading(db, readingID: id, limit: probe))
            }) {
                truncated = value.entries.count > window
                entries = Array(value.entries.prefix(window))
                reading = value.reading
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// The list grouped by the assembly's own section transitions —
    /// pure, pinned. `section` nil ⇒ unsectioned rows (no header).
    var groupedRows: [(section: String?, entries: [Queries.ReadingEntry])] {
        Self.grouped(entries)
    }

    nonisolated static func grouped(
        _ entries: [Queries.ReadingEntry]
    ) -> [(section: String?, entries: [Queries.ReadingEntry])] {
        var groups: [(section: String?, entries: [Queries.ReadingEntry])] = []
        for entry in entries {
            if let last = groups.indices.last, groups[last].section == entry.sectionPath {
                groups[last].entries.append(entry)
            } else {
                groups.append((section: entry.sectionPath, entries: [entry]))
            }
        }
        return groups
    }

    /// A row's display name — the ONE display brain (13k K1).
    nonisolated static func rowTitle(_ entry: Queries.ReadingEntry) -> String {
        DisplayTitle.note(
            title: entry.title, entryDate: entry.entryDate, createdAt: entry.createdAt)
    }

    /// A section header's displayed text: chapter names pass through;
    /// tag-grouping paths show their leaf (the K3 doctrine).
    nonisolated static func sectionLabel(_ section: String) -> String {
        MobileShelfFaces.leaf(section)
    }
}
