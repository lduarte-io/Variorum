import Foundation

/// **U+0000 NEVER REACHES THE STORE** (VX-357 — her ruling 2026-10-15, the
/// shape she approved; the run record `notes/plans/fixes/vx-348-prelaunch-sweep.md`,
/// U1 UNIT RECORD).
///
/// The mechanism this rule answers: GRDB binds TEXT with length -1
/// (`sqlite3_bind_text(…, -1, …)` — `GRDB/Core/Support/StandardLibrary/StandardLibrary.swift:625`),
/// so SQLite reads a bound value only up to its first NUL. A take written as
/// "before\0after" landed as "before": everything after the null character was
/// silently LOST, on every road text reaches the store — a paste, an import, a
/// comment, a title, a label, a name, the MCP door. Her words: *"stripping it
/// silently seems the easiest to handle (or stripping it and saying that it was
/// stripped when it happens as a mix of option 1 & 2 I suppose)"*. Not chosen:
/// refusing (it rejects a whole paste over an invisible character) and storing
/// faithfully (a change to how text is bound to SQLite, for a character with no
/// use in writing).
///
/// **The rule, whole: every U+0000 is removed, and nothing else changes.** No
/// trimming, no normalization, no other control character touched — the store
/// keeps exactly what was written, minus the one character it cannot hold. The
/// character is invisible and means nothing in prose, so on her own doors the
/// strip is quiet; the MCP door always says it (the answer names how many were
/// removed — `VariorumMCP`'s `null_characters_removed`).
///
/// **Where it applies — ONE rule, the operations layer** (never door by door):
/// every operation that writes caller-supplied text into a text column passes
/// it through `stripped` FIRST, before its validation, its no-op guard and its
/// counts, so each of them sees exactly the text that will be stored; and the
/// shared mints (`mintBlock`, `mintFanBlock`, `insertPost`, `insertTag`) apply
/// it again at the row, so no mint road — a future one included — can store a
/// null character. Stored text never holds one (a bind cannot write it), so
/// copies of stored text are already clean; applying the rule to them is a
/// no-op.
///
/// Byte-level and exact: in UTF-8 the byte 0x00 occurs ONLY as U+0000 itself
/// (every byte of a multi-byte sequence is ≥ 0x80), so removing the 0x00 bytes
/// removes exactly the null characters and leaves valid UTF-8. Cost ∝ the text,
/// with a no-allocation fast path when there is nothing to remove — the text a
/// write binds is already ∝ the edit (P1).
///
/// Pure and dependency-free — no GRDB, no AppKit.
public enum StoredText {
    /// The text as the store keeps it: every U+0000 removed, nothing else
    /// touched. Returns `text` itself when it holds none.
    public static func stripped(_ text: String) -> String {
        guard containsNull(text) else { return text }
        return String(decoding: text.utf8.filter { $0 != 0 }, as: UTF8.self)
    }

    /// `stripped` over an optional — nil stays nil (a cleared field).
    public static func stripped(_ text: String?) -> String? {
        text.map(stripped)
    }

    /// Whether the text holds a U+0000 at all.
    public static func containsNull(_ text: String) -> Bool {
        text.utf8.contains(0)
    }

    /// How many U+0000 characters `stripped` removes from this text — what the
    /// MCP door says back.
    public static func nullCount(_ text: String) -> Int {
        guard containsNull(text) else { return 0 }
        return text.utf8.reduce(0) { $0 + ($1 == 0 ? 1 : 0) }
    }

    /// `nullCount` over an optional (nil counts none).
    public static func nullCount(_ text: String?) -> Int {
        text.map(nullCount) ?? 0
    }

    /// **The same words in another SPELLING** (VX-358 — RUN VX-548 batch 2a,
    /// PROVISIONAL MB-5): `text` equals `stored` under Swift's `String`
    /// equality — CANONICAL equivalence, the rule every text no-op guard here
    /// uses (an NFC "é" equals its NFD "e" + U+0301) — while their UTF-8
    /// bytes differ. The store keeps exactly what was written (no
    /// normalization — `stripped` touches only U+0000), so such a write is a
    /// no-op that the stored bytes, and the wire's digest of them (VX-254),
    /// do not match; the MCP door says so (`stored_text_normalization_differs`).
    /// False for byte-identical texts and for texts that differ in meaning.
    /// Pure; cost ∝ the texts (only reached on a no-op, whose text is ∝ the
    /// edit).
    public static func spellingDiffers(_ text: String, from stored: String) -> Bool {
        text == stored && !text.utf8.elementsEqual(stored.utf8)
    }
}
