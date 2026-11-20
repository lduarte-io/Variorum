//
//  TimingBook.swift
//  VariorumCore
//
//  VM-65 (the VM-64 run, batch 1) — THE TIMING RECORD, ONE TABLE PER BUILD.
//  The author's sharpening of the batch (2026-11-19, relayed mid-batch; the
//  record's §5 and §7): the BEFORE build goes on her phone at a later sitting
//  and may live there for days; the AFTER build is installed over it much
//  later; she reads the before-and-after on the phone itself. So:
//
//  · a table per BUILD — a new build never blends its samples into the old
//    one's (the caller's build key decides what "a build" is);
//  · the PREVIOUS build's table stays readable beside this one's;
//  · BOUNDED: at most `keptBuilds` tables — this build's and the one before
//    it. Opening a third build drops the oldest; that is the only thing that
//    ever clears a previous table (PROVISIONAL P-65-4 — the simple rule);
//  · Codable, so the app writes it to one small file in its own container.
//
//  Pure value semantics; numbers and the caller's build keys and labels only.
//

import Foundation

public struct TimingBook: Codable, Sendable, Equatable {
    public static let currentVersion = 1
    /// This build's table and the previous build's.
    public static let keptBuilds = 2

    public var version: Int
    /// Most recently opened first: `[0]` is the build running now (once
    /// `open` has run), `[1]` the one before it.
    public private(set) var builds: [TimingArchive]

    public init() {
        version = TimingBook.currentVersion
        builds = []
    }

    /// The running build's table.
    public var current: TimingArchive? { builds.first }
    /// The previous build's table, when one is kept.
    public var previous: TimingArchive? { builds.dropFirst().first }

    /// The build now running takes the front. Its kept table, if it has one,
    /// moves there and is returned (the recorder absorbs it); otherwise an
    /// empty table for it is placed there and the table that WAS in front
    /// becomes the previous one. Tables beyond `keptBuilds` — the oldest — are
    /// dropped. The label is refreshed either way (display only).
    @discardableResult
    public mutating func open(build: String, label: String) -> TimingArchive? {
        if let index = builds.firstIndex(where: { $0.build == build }) {
            var kept = builds.remove(at: index)
            kept.label = label
            builds.insert(kept, at: 0)
            trim()
            return kept
        }
        builds.insert(TimingArchive(build: build, label: label), at: 0)
        trim()
        return nil
    }

    /// Keeps `archive` as its build's table: it replaces that build's table
    /// where one is kept, or takes the front where none is (then the oldest
    /// beyond the bound is dropped). Never touches another build's table.
    public mutating func store(_ archive: TimingArchive) {
        if let index = builds.firstIndex(where: { $0.build == archive.build }) {
            builds[index] = archive
        } else {
            builds.insert(archive, at: 0)
            trim()
        }
    }

    /// The book `data` holds, or nil when it is not one this version reads
    /// (a malformed or future file starts a fresh book — the numbers are
    /// diagnostics, never her work).
    public static func decode(_ data: Data) -> TimingBook? {
        guard var book = try? JSONDecoder().decode(TimingBook.self, from: data),
              book.version == currentVersion
        else { return nil }
        book.builds.removeAll { $0.version != TimingArchive.currentVersion }
        book.trim()
        return book
    }

    /// The book as the bytes the app writes.
    public func encoded() throws -> Data {
        try JSONEncoder().encode(self)
    }

    private mutating func trim() {
        if builds.count > TimingBook.keptBuilds {
            builds.removeLast(builds.count - TimingBook.keptBuilds)
        }
    }
}
