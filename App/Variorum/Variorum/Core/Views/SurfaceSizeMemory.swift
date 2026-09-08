//
//  SurfaceSizeMemory.swift
//  Variorum (Mac) — Core/Views (the shared Mac-chrome home)
//
//  18d batch 4 (U-12 — *"I see no reason why we wouldn't add in remembering
//  the length of notes so it can be perfect after the first time"*; ledger
//  row 25). SPLIT OUT of `StableSurface.swift`, where it was born at the
//  Act 10 correction round's batch H as a plain session dictionary, and
//  GROWN into the one persisted store behind both remembered-size
//  surfaces: the book Outline's expanded notes (`BookViewModel`) and the
//  Read ▸ Scroll flow's stories. Not a byte of `StableSurface` changed —
//  the reservation, the width refusal and R1-1's settle rule are exactly
//  what they were, and `StableSurfaceTests` rides unmodified. What changed
//  is only WHERE the size a surface settled at goes when the app quits.
//
//  **Local-only, never synced** (the `currentBlock.<id>` / `postMode.<id>`
//  class): a remembered height is this machine's geometry at this
//  machine's window width — it is view state, not truth (CLAUDE.md), and
//  it has no home in the store, no schema, no lockstep event.
//
//  **The write cadence is the whole design.** `remember` is called at
//  GEOMETRY cadence — every report while a surface loads, and on every
//  keystroke's height change in a live editor (`followsShrinks`) — and
//  `UserDefaults.standard.set` costs ~100 µs a call on this machine
//  (measured at 17o batch b, `CurrentBlockMemory`'s own note). So
//  `remember` writes the SESSION record and nothing else; the disk is
//  written by `persist`, which the consumers call from `StableSurface`'s
//  own `settled` announcement — the moment a surface has held one size for
//  the settle interval, adopted it, and dropped its reservation. One write
//  per settled size, and none at all when the settle re-adopts the size
//  already on disk. A hard quit inside the settle interval can cost at
//  most the last second's height change, which the settle rule re-adopts a
//  second after the next open.
//
//  **Why UserDefaults and not a local-only table.** One small key per note
//  per surface family, exactly the shape the app already ships twice
//  (`currentBlock.<id>`, `postMode.<id>`); a thousand notes browsed in
//  both surfaces is ~2,000 keys of ~40 bytes. The count does not argue for
//  a table, and a table would owe a migration for view state that a
//  `defaults delete` should be allowed to end.
//

import Foundation

/// The last settled size of each surface, keyed by post — remembered for
/// the session and, for a namespaced memory, across launches.
@MainActor
final class SurfaceSizeMemory {
    /// A surface FAMILY: one measure, one key space. The Outline's notes
    /// stand at Write's measure and the flow's stories at the reading
    /// page's, so a note has a different height in each and the two
    /// memories must never meet (they would refuse each other's width
    /// forever, one settle at a time).
    enum Namespace: String {
        /// The book Outline's expanded notes (live and read-cheap alike —
        /// one measure, the caller's `.id` starting a fresh reservation).
        case outline
        /// The Read ▸ Scroll flow's stories.
        case flow
    }

    /// The defaults key for one surface. `surfaceSize.<family>.<postID>`.
    static func key(_ namespace: Namespace, _ surface: String) -> String {
        "surfaceSize.\(namespace.rawValue).\(surface)"
    }

    /// A remembered size and the TYPOGRAPHY it was taken under — persisted
    /// as `w|h|fingerprint`.
    ///
    /// The fingerprint is the second half of the memory's honesty.
    /// `StableSurface` already refuses a memory taken at another WIDTH
    /// (`stableSurfaceWidthTolerance`), which catches the window resizing
    /// and the sidebar collapsing; it cannot catch the text getting
    /// taller at the SAME width, which is what the voice switch does
    /// (Terminal's 14-pt monospace ↔ Study's 16-pt Iowan) and what turning
    /// inline comments on does (a comment strip's room per paragraph).
    /// A memory stamped with a typography that is no longer current is
    /// refused exactly as a memory at another width is — the surface
    /// starts from its own first report and settles into a fresh memory a
    /// second later.
    struct Record: Equatable {
        var size: CGSize
        var fingerprint: String

        init(size: CGSize, fingerprint: String) {
            self.size = size
            self.fingerprint = fingerprint
        }

        /// Rounded to a tenth of a point: the strings stay short and the
        /// error is two orders of magnitude inside the width tolerance
        /// that reads them.
        var encoded: String {
            "\(Self.round(size.width))|\(Self.round(size.height))|\(fingerprint)"
        }

        private static func round(_ value: CGFloat) -> Double {
            (Double(value) * 10).rounded() / 10
        }

        /// nil for anything this app did not write, or wrote in a shape it
        /// no longer speaks: a memory is view state, so an unreadable one
        /// is simply no memory (never an error, never a crash).
        init?(_ encoded: String) {
            let parts = encoded.split(separator: "|", maxSplits: 2, omittingEmptySubsequences: false)
            guard parts.count == 3,
                  let width = Double(parts[0]), let height = Double(parts[1]),
                  width.isFinite, height.isFinite, width > 0, height > 0
            else { return nil }
            self.size = CGSize(width: width, height: height)
            self.fingerprint = String(parts[2])
        }
    }

    /// nil ⇒ session-only (the pre-18d behaviour, kept for the test hosts
    /// and any future embedding that should not outlive its window).
    private let namespace: Namespace?
    private let defaults: UserDefaults
    /// The typography the CURRENT frame stands in — read live at every
    /// read and every remember, never cached, so a voice switch is felt
    /// inside the session and not only after a relaunch.
    private let fingerprint: () -> String

    /// The session's word. Read before the disk and never invalidated by
    /// it: what a surface reported this session outranks what a previous
    /// one wrote.
    private var records: [String: Record] = [:]
    /// Which surfaces the disk has already been asked about — so a row
    /// realized a hundred times per scroll reads `UserDefaults` once.
    private var consulted: Set<String> = []
    /// What is on disk for each surface, so a settle that re-adopts the
    /// size already written costs no write at all.
    private var written: [String: String] = [:]

    /// A session-only memory (batch H's original).
    init() {
        self.namespace = nil
        self.defaults = .standard
        self.fingerprint = { "" }
    }

    /// A memory that outlives the launch.
    init(
        _ namespace: Namespace,
        defaults: UserDefaults = .standard,
        fingerprint: @escaping () -> String
    ) {
        self.namespace = namespace
        self.defaults = defaults
        self.fingerprint = fingerprint
    }

    /// The remembered size of a surface, if one applies HERE — the session's
    /// record first, the persisted one behind it, and either only when it
    /// was taken under the typography now in force.
    func size(_ key: String) -> CGSize? {
        guard let record = record(key), record.fingerprint == fingerprint() else { return nil }
        return record.size
    }

    /// A surface reported its size — geometry cadence, session only. The
    /// disk waits for `persist`.
    func remember(_ key: String, _ size: CGSize) {
        records[key] = Record(size: size, fingerprint: fingerprint())
        consulted.insert(key)
    }

    /// The surface SETTLED (`StableSurface`'s own announcement): write what
    /// the session holds, unless the disk already says it.
    func persist(_ key: String) {
        guard let namespace, let record = records[key] else { return }
        let encoded = record.encoded
        guard written[key] != encoded else { return }
        written[key] = encoded
        defaults.set(encoded, forKey: Self.key(namespace, key))
    }

    /// Drop a surface's memory here and on disk (the note is gone, or a
    /// pin resets).
    func forget(_ key: String) {
        records[key] = nil
        written[key] = nil
        consulted.insert(key)
        guard let namespace else { return }
        defaults.removeObject(forKey: Self.key(namespace, key))
    }

    private func record(_ key: String) -> Record? {
        if let record = records[key] { return record }
        guard let namespace, !consulted.contains(key) else { return nil }
        consulted.insert(key)
        guard let stored = defaults.string(forKey: Self.key(namespace, key)),
              let record = Record(stored)
        else { return nil }
        records[key] = record
        written[key] = stored
        return record
    }
}
