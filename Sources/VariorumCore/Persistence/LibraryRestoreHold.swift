import Foundation

// Phase 13x, U2 row 7 — THE RESTORE-HOLD FLAG (the round-3 ruling: adopting
// a copy lands the library OPEN with sync WAITING — a landing state, not a
// toggle; one landing state everywhere a copy is adopted, BOTH doors).
//
// The flag is a MARKER FILE beside the store (`variorum-restore-hold.json`),
// per-store BY LOCATION — "held after restore" is a fact about the file
// sitting at the store path, exactly what the location encodes. It is set
// by the landing itself (13x's `LibraryAdoption.execute`, step 3½ — F1
// R1-M2: before the move, so nothing ever lands un-held; since VX-329 U1 the
// road's copy doors, the restore hold by the core writer), cleared
// by the one Resume press, and consulted at the round-trigger seam
// (`Shared`'s `SyncSession` — the un-followed device's refused-rounds
// precedent re-worn). It never travels: the hand-off folder and every
// snapshot pair carry only the store and its key file. The marker is NOT
// in the move-aside's departing set (store, sidecars and key files only
// — 13x F1 R1-N3's correction of this header's earlier claim): the
// guarantee against a stale marker is that EVERY adoption rewrites it
// and Resume alone clears it.
//
// Deliberately NOT a row in `sync_state`: that table is the engine's
// (writes there from door code would be ad-hoc row edits below the
// operations API), it rides ciphertext backups (the flag must describe
// THIS landing, never the copy's past), and the plaintext export drops it.

public enum LibraryRestoreHold {
    public struct Hold: Codable, Equatable, Sendable {
        /// When the hold was written (the adoption's completion).
        public var heldAt: Date
        /// The adopted copy's own day — the banner's "your library as of
        /// <date>" (a backup stamp where the name carries one, else the
        /// source file's modification date; nil = unknown, the banner
        /// drops the clause).
        public var asOf: Date?

        public init(heldAt: Date, asOf: Date?) {
            self.heldAt = heldAt
            self.asOf = asOf
        }
    }

    public static let filename = "variorum-restore-hold.json"

    public static func markerURL(besideStore storeURL: URL) -> URL {
        storeURL.deletingLastPathComponent()
            .appendingPathComponent(filename, isDirectory: false)
    }

    /// Write the hold (the adoption door's completion act). Overwrites any
    /// standing marker — every adoption lands its own hold.
    public static func set(besideStore storeURL: URL, asOf: Date?, now: Date) throws {
        let hold = Hold(heldAt: now, asOf: asOf)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        try encoder.encode(hold).write(to: markerURL(besideStore: storeURL), options: .atomic)
    }

    /// The standing hold, nil when none. An unreadable marker reads as a
    /// HOLD with unknown facts, never as absence — a torn file must not
    /// silently resume sync (the P1/P11 honesty rule's direction: the
    /// conservative reading is held; Resume clears it either way).
    public static func read(besideStore storeURL: URL) -> Hold? {
        let url = markerURL(besideStore: storeURL)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        guard let data = try? Data(contentsOf: url) else {
            return Hold(heldAt: .distantPast, asOf: nil)
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let hold = try? decoder.decode(Hold.self, from: data) else {
            return Hold(heldAt: .distantPast, asOf: nil)
        }
        return hold
    }

    /// Whether rounds are held for the store at this path — the round-
    /// trigger seam's one consult.
    public static func isHeld(besideStore storeURL: URL) -> Bool {
        read(besideStore: storeURL) != nil
    }

    /// Resume's clear (the one press). True when the marker is gone after
    /// the call (removed, or never there).
    @discardableResult
    public static func clear(besideStore storeURL: URL) -> Bool {
        let url = markerURL(besideStore: storeURL)
        guard FileManager.default.fileExists(atPath: url.path) else { return true }
        return (try? FileManager.default.removeItem(at: url)) != nil
    }
}
